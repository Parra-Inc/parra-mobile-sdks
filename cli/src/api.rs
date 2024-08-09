use crate::{
    auth,
    types::{
        api::{
            ApplicationCollectionResponse, ApplicationRequest,
            ApplicationResponse, ApplicationType, AuthorizedUser,
            TenantRequest, TenantResponse, UserInfoResponse, UserResponse,
        },
        auth::Credental,
    },
};
use serde::{de::DeserializeOwned, Serialize};
use std::error::Error;

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
        &authorized_user.credential,
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
        &authorized_user.credential,
        &endpoint,
        reqwest::Method::POST,
        body,
    )
    .await?;

    Ok(response)
}

pub async fn get_current_user(
    credential: &Credental,
) -> Result<UserResponse, Box<dyn Error>> {
    let response: UserInfoResponse =
        perform_get_request(&credential, "/user-info", vec![]).await?;

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

async fn perform_get_request<T: DeserializeOwned>(
    credential: &Credental,
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

            Ok(serde_json::from_str::<T>(&body)?)
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
    credential: &Credental,
    endpoint: &str,
    method: reqwest::Method,
    body: U,
) -> Result<T, Box<dyn Error>> {
    let url = format!("https://api.parra.io/v1{}", endpoint);
    let client = reqwest::Client::new();
    let token = &credential.token;

    let mut request = client.request(method.clone(), url).bearer_auth(token);

    if method != reqwest::Method::GET {
        request = request.json(&body);
    }

    let response = request.send().await?;

    if !response.status().is_success() {
        let body = response.text().await?;
        return Err(format!("Error response received: {}", body).into());
    }

    let body = response.text().await?;

    Ok(serde_json::from_str::<T>(&body)?)
}
