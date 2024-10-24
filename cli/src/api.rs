use crate::{
    auth,
    types::{
        api::{
            ApplicationCollectionResponse, ApplicationRequest,
            ApplicationResponse, ApplicationType, AuthorizedUser, EmptyRequest,
            EmptyResponse, EventRequest, SessionRequest, TenantRequest,
            TenantResponse, UserInfoResponse, UserResponse,
        },
        auth::Credential,
    },
};
use chrono::{DateTime, Utc};

use async_recursion::async_recursion;
use serde::{de::DeserializeOwned, Serialize};
use std::sync::Mutex;
use std::time::{SystemTime, UNIX_EPOCH};
use std::{collections::HashMap, error::Error};

#[async_recursion(?Send)]
pub async fn report_event(
    event_name: &str,
    metadata: Option<HashMap<&str, &str>>,
) {
    // POST /tracking/sessions

    let authorized_user = get_cached_user_if_present().await;

    let credential: Option<Credential> =
        if let Some(authorized_user) = authorized_user {
            Some(authorized_user.credential)
        } else {
            None
        };

    let now = SystemTime::now();
    let duration = now
        .duration_since(UNIX_EPOCH)
        .expect("SystemTime before UNIX EPOCH!");
    let date_time = DateTime::<Utc>::from_timestamp(
        duration.as_secs() as i64,
        duration.subsec_nanos(),
    )
    .expect("Invalid timestamp");

    let endpoint = "/tracking/sessions";
    let body = SessionRequest {
        events: vec![EventRequest {
            name: event_name.to_string(),
            created_at: date_time.to_rfc3339(),
            metadata: metadata.unwrap_or(HashMap::from([])),
        }],
    };

    let result: Result<EmptyResponse, Box<dyn Error>> =
        perform_request_with_body(
            credential.as_ref(),
            &endpoint,
            reqwest::Method::POST,
            body,
        )
        .await;

    match result {
        Ok(_) => {}
        Err(error) => {
            eprintln!(
                "Error reporting event: {} - error: {}",
                event_name,
                error.to_string()
            )
        }
    };
}

pub async fn get_tenant(
    tenant_id: &str,
) -> Result<TenantResponse, Box<dyn Error>> {
    // get-tenant-by-id

    let authorized_user = ensure_auth().await?;

    let endpoint = format!("/tenants/{}", tenant_id);
    let response: TenantResponse =
        perform_get_request(&authorized_user.credential, &endpoint, vec![])
            .await?;

    Ok(response)
}

pub async fn get_tenants() -> Result<Vec<TenantResponse>, Box<dyn Error>> {
    // get-tenants-for-user-by-id

    let authorized_user = ensure_auth().await?;

    let endpoint = format!("/users/{}/tenants", authorized_user.user.id);
    let tenants: Vec<TenantResponse> =
        perform_get_request(&authorized_user.credential, &endpoint, vec![])
            .await?;

    Ok(tenants)
}

pub async fn complete_bootstrap(
    tenant_id: &str,
    application_id: &str,
) -> Result<(), Box<dyn Error>> {
    let authorized_user = ensure_auth().await?;

    let endpoint = format!(
        "/tenants/{}/applications/{}/bootstrap",
        tenant_id, application_id
    );

    let body = EmptyRequest {};

    let result: Result<EmptyResponse, Box<dyn Error>> =
        perform_request_with_body(
            Some(&authorized_user.credential),
            &endpoint,
            reqwest::Method::POST,
            body,
        )
        .await;

    match result {
        Ok(_) => Ok(()),
        Err(error) => {
            eprintln!(
                "Error completing bootstrap - error: {}",
                error.to_string()
            );

            Err(error)
        }
    }
}

pub async fn create_tenant(
    name: &str,
) -> Result<TenantResponse, Box<dyn Error>> {
    // create-tenant-for-user-by-id
    let authorized_user = ensure_auth().await?;

    let endpoint = format!("/users/{}/tenants", authorized_user.user.id);
    let body = TenantRequest {
        name: name.to_string(),
        is_test: false,
    };

    let response: TenantResponse = perform_request_with_body(
        Some(&authorized_user.credential),
        &endpoint,
        reqwest::Method::POST,
        body,
    )
    .await?;

    Ok(response)
}

pub async fn paginate_applications(
    tenant_id: &str,
) -> Result<Vec<ApplicationResponse>, Box<dyn Error>> {
    // paginate-applications-for-tenant-by-id

    let authorized_user = ensure_auth().await?;
    let query = vec![("$top", "10000")];

    let endpoint = format!("/tenants/{}/applications", tenant_id);
    let response: ApplicationCollectionResponse =
        perform_get_request(&authorized_user.credential, &endpoint, query)
            .await?;
    let applications = response.data;

    Ok(applications)
}

pub async fn get_application(
    tenant_id: &str,
    application_id: &str,
) -> Result<ApplicationResponse, Box<dyn Error>> {
    // get-application-by-id-for-tenant-by-id

    let authorized_user = ensure_auth().await?;

    let endpoint =
        format!("/tenants/{}/applications/{}", tenant_id, application_id);
    let response: ApplicationResponse =
        perform_get_request(&authorized_user.credential, &endpoint, vec![])
            .await?;

    Ok(response)
}

pub async fn create_application(
    tenant_id: &str,
    name: &str,
    bundle_id: &str,
) -> Result<ApplicationResponse, Box<dyn Error>> {
    // create-application-for-tenant-by-id

    let authorized_user = ensure_auth().await?;

    let endpoint = format!("/tenants/{}/applications", tenant_id);
    let body = ApplicationRequest {
        name: name.to_string(),
        description: None,
        r#type: ApplicationType::Ios,
        ios_bundle_id: bundle_id.to_string(),
        is_new_project: true,
    };

    let response: ApplicationResponse = perform_request_with_body(
        Some(&authorized_user.credential),
        &endpoint,
        reqwest::Method::POST,
        body,
    )
    .await?;

    Ok(response)
}

static CURRENT_USER: Mutex<Option<UserResponse>> = Mutex::new(None);

pub async fn get_current_user(
    credential: &Credential,
) -> Result<UserResponse, Box<dyn Error>> {
    if let Ok(guard) = CURRENT_USER.lock() {
        if let Some(user) = &*guard {
            return Ok(user.clone());
        }
    }

    let response: UserInfoResponse =
        perform_get_request(&credential, "/user-info", vec![]).await?;

    if let Ok(mut guard) = CURRENT_USER.lock() {
        *guard = Some(response.user.clone());
    }

    return Ok(response.user);
}

async fn ensure_auth() -> Result<AuthorizedUser, Box<dyn Error>> {
    let (credential, _) = auth::perform_device_authentication().await?;

    let user = get_current_user(&credential).await?;

    Ok(AuthorizedUser {
        credential,
        user: user,
    })
}

async fn get_cached_user_if_present() -> Option<AuthorizedUser> {
    let result = auth::perform_device_authentication().await;

    match result {
        Ok((credential, _)) => {
            let user_result = get_current_user(&credential).await;

            match user_result {
                Ok(user) => Some(AuthorizedUser {
                    credential: credential,
                    user: user,
                }),
                Err(_) => None,
            }
        }
        Err(_) => None,
    }
}

async fn perform_get_request<T: DeserializeOwned>(
    credential: &Credential,
    endpoint: &str,
    query: Vec<(&str, &str)>,
) -> Result<T, Box<dyn Error>> {
    let url = format!("https://api.parra.io/v1{}", endpoint);
    let client = reqwest::Client::new();
    let token = &credential.token.trim();

    let request = client
        .request(reqwest::Method::GET, url.clone())
        .query(&query)
        .bearer_auth(token);

    let response = request.send().await?;

    match response.error_for_status() {
        Ok(_res) => {
            let body = _res.text().await?;

            parse_json_response(&body)
        }
        Err(err) => {
            eprintln!(
                "Error performing request to: {} error: {}",
                url.clone(),
                err
            );

            Err(err.into())
        }
    }
}

async fn perform_request_with_body<T: DeserializeOwned, U: Serialize>(
    credential: Option<&Credential>,
    endpoint: &str,
    method: reqwest::Method,
    body: U,
) -> Result<T, Box<dyn Error>> {
    let url = format!("https://api.parra.io/v1{}", endpoint);
    let client = reqwest::Client::new();

    let mut request = client.request(method.clone(), url);

    if let Some(credential) = credential {
        request = request.bearer_auth(&credential.token)
    }

    if method != reqwest::Method::GET {
        request = request.json(&body);
    }

    let response = request.send().await?;

    if !response.status().is_success() {
        let body = response.text().await?;
        return Err(format!("Error response received: {}", body).into());
    }

    let mut body = response.text().await?;
    if body.is_empty() {
        body = "{}".to_string();
    }

    parse_json_response(&body)
}

fn parse_json_response<T: DeserializeOwned>(
    body: &String,
) -> Result<T, Box<dyn Error>> {
    match serde_json::from_str::<T>(&body) {
        Ok(result) => Ok(result),
        Err(err) => {
            eprintln!("Error decoding JSON response: {}", err);

            Err(Box::new(err))
        }
    }
}
