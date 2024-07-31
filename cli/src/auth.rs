use crate::types::auth::{
    AuthResponse, Credental, DeviceAuthResponse, RefreshResponse, TokenRequest,
};
use inquire::Confirm;
use serde::de::DeserializeOwned;
use std::error::Error;
use std::ops::Add;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

const SERVICE_NAME: &str = "parra_cli";
const AUTH0_CLIENT_ID: &str = "nD9GTUvvqCT0oWi34L2IdJiK0YjupSjY";

pub fn logout() -> Result<(), Box<dyn Error>> {
    let result = security_framework::passwords::delete_generic_password(
        SERVICE_NAME,
        AUTH0_CLIENT_ID,
    );

    match result {
        Ok(_) => Ok(()),

        Err(error) => Err(error.into()),
    }
}

pub async fn perform_device_authentication() -> Result<Credental, Box<dyn Error>>
{
    match get_persisted_credential() {
        Ok(credential) => {
            let now = SystemTime::now();
            let timestamp = now.duration_since(UNIX_EPOCH)?.as_secs();

            // Token is either already expired or about to expire
            if timestamp > credential.expiry - 30 {
                return perform_refresh_authentication(&credential).await;
            } else {
                return Ok(credential);
            }
        }
        Err(_) => {
            return perform_normal_authentication().await;
        }
    }
}

async fn perform_refresh_authentication(
    credential: &Credental,
) -> Result<Credental, Box<dyn Error>> {
    let result: Result<RefreshResponse, Box<dyn Error>> = post_form_request(
        "https://auth.parra.io/oauth/token",
        vec![
            ("client_id".to_string(), AUTH0_CLIENT_ID.to_string()),
            (
                "refresh_token".to_string(),
                credential.refresh_token.to_string(),
            ),
            ("grant_type".to_string(), "refresh_token".to_string()),
        ],
    )
    .await;

    let refresh_response = result?;

    println!("Reauthentication successful!");

    return persist_refresh_credential(&refresh_response, &credential);
}

async fn perform_normal_authentication() -> Result<Credental, Box<dyn Error>> {
    let device_code_url = "https://auth.parra.io/oauth/device/code";

    let device_auth_response: Result<DeviceAuthResponse, Box<dyn Error>> =
        post_form_request(
            device_code_url,
            vec![
                ("client_id".to_string(), AUTH0_CLIENT_ID.to_string()),
                ("scope".to_string(), "offline_access".to_string()),
            ],
        )
        .await;

    let device_auth = device_auth_response.unwrap();

    // confirm that the user wants to open the browser
    let confirm_message =
        format!("We need to confirm your identity in the browser. Press enter to open the browser.");
    let help_message = format!(
        "If the browser doesn't open automatically, visit {} and enter the code: {} to confirm your login.",
        device_auth.verification_uri, device_auth.user_code
    );

    let confirmed = Confirm::new(&confirm_message)
        .with_default(true)
        .with_help_message(&help_message)
        .prompt()?;

    if !confirmed {
        return Err("Authentication cancelled".into());
    }

    let result = open::that(device_auth.verification_uri_complete);

    if result.is_err() {
        println!(
            "Failed to open the browser. Please visit {} and enter the code: {} to confirm your login.",
            device_auth.verification_uri,
            device_auth.user_code
        );
    }

    // begin polling for the token
    let token_url = "https://auth.parra.io/oauth/token";

    let token_request_body = TokenRequest {
        client_id: AUTH0_CLIENT_ID.to_string(),
        device_code: device_auth.device_code,
        grant_type: "urn:ietf:params:oauth:grant-type:device_code".to_string(),
    };

    // Strictly speaking, the polling should begin before the user is prompted. But since
    // we don't have a UI that requires user interaction to launch the browser, and we
    // aren't awaiting the result of that web page being opened, we can launch it, then
    // begin polling.
    let poll_result = poll_for_token::<AuthResponse>(
        token_url,
        device_auth.interval,
        device_auth.expires_in,
        token_request_body,
    )
    .await?;

    println!("Authentication successful!");

    return persist_credential(
        &poll_result.access_token,
        poll_result.expires_in,
        &poll_result.refresh_token,
    );
}

fn get_persisted_credential() -> Result<Credental, Box<dyn Error>> {
    let data = security_framework::passwords::get_generic_password(
        SERVICE_NAME,
        AUTH0_CLIENT_ID,
    )?;

    let data = String::from_utf8(data)?;

    return Ok(serde_json::from_str::<Credental>(&data)?);
}

fn persist_refresh_credential(
    data: &RefreshResponse,
    existing_credential: &Credental,
) -> Result<Credental, Box<dyn Error>> {
    let next_credential = Credental {
        token: data.access_token.clone(),
        refresh_token: existing_credential.refresh_token.clone(),
        expiry: existing_credential.expiry,
    };

    return persist_credential(
        &next_credential.token,
        data.expires_in,
        &next_credential.refresh_token,
    );
}

fn persist_credential(
    access_token: &str,
    expires_in: u64,
    refresh_token: &str,
) -> Result<Credental, Box<dyn Error>> {
    let now = SystemTime::now();
    let mut expiry = now.duration_since(UNIX_EPOCH)?;
    expiry = expiry.add(Duration::from_secs(expires_in));

    let credential = Credental {
        token: access_token.to_string(),
        expiry: expiry.as_secs(),
        refresh_token: refresh_token.to_string(),
    };

    let serialized = serde_json::to_string(&credential).unwrap();

    security_framework::passwords::set_generic_password(
        SERVICE_NAME,
        AUTH0_CLIENT_ID,
        serialized.as_bytes(),
    )?;

    Ok(credential)
}

async fn post_form_request<T: DeserializeOwned>(
    url: &str,
    fields: Vec<(String, String)>,
) -> Result<T, Box<dyn Error>> {
    let client = reqwest::Client::new();
    let response = client.post(url).form(&fields).send().await?;

    let status = response.status();
    let body = response.text().await?;

    if status.is_success() {
        return Ok(serde_json::from_str::<T>(&body)?);
    } else {
        eprintln!("Request failed with status {}: {}", status, body);
        return Err("Request failed".into());
    }
}

async fn poll_for_token<T: DeserializeOwned>(
    url: &str,
    interval: u64,
    expires_in: u64,
    body: TokenRequest,
) -> Result<T, Box<dyn Error>> {
    let interval = Duration::from_secs(interval);
    let start_time = Instant::now();
    let expires_in = Duration::from_secs(expires_in);

    let client = reqwest::Client::new();

    loop {
        // spec says to wait for the interval before the first poll
        async_std::task::sleep(interval).await;

        if start_time.elapsed() >= expires_in {
            return Err("Parra sign in request has expired. Try again.".into());
        }

        let response = client.post(url).json(&body).send().await?;
        let status = response.status();
        let body = response.text().await?;

        if status.is_success() {
            return Ok(serde_json::from_str::<T>(&body)?);
        } else if status.as_u16() == 403 {
            println!("Waiting for authorization from the browser...");
        } else {
            eprintln!(
                "Check for authorization token failed unexpectedly {}: {}",
                status, body
            );

            return Err("Request failed".into());
        }
    }
}
