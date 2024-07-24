use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct Credental {
    pub token: String,
    pub refresh_token: String,
    pub expiry: u64,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AuthResponse {
    pub access_token: String,
    pub refresh_token: String,
    pub scope: String,
    pub expires_in: u64,
    pub token_type: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct RefreshResponse {
    pub access_token: String,
    pub scope: String,
    pub expires_in: u64,
    pub token_type: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct DeviceAuthResponse {
    /// Do not show this to the user. It is used to poll for the token.
    pub device_code: String,
    pub user_code: String,
    pub verification_uri: String,
    pub verification_uri_complete: String,
    /// lifetime in seconds for device_code and user_code. Default 900.
    pub expires_in: u64,
    /// The interval to poll the token endpoint. Default 5.
    pub interval: u64,
}

#[derive(Debug, Serialize)]
pub struct TokenRequest {
    pub grant_type: String,
    pub device_code: String,
    pub client_id: String,
}
