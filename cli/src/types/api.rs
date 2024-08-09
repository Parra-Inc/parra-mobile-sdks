use serde::{Deserialize, Serialize};

use super::auth::Credental;

#[derive(Debug, Deserialize)]
pub struct UserResponse {
    pub id: String,
    /// Will be nil in cases where the user registered for a new account during auth
    /// flow in the browser, since they won't have completed onboarding.
    pub name: Option<String>,
    pub email: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UserInfoResponse {
    pub user: UserResponse,
}

#[derive(Debug)]
pub struct AuthorizedUser {
    pub credential: Credental,
    pub user: UserResponse,
}

#[derive(Debug, Serialize)]
pub struct TenantRequest {
    pub name: String,
    pub is_test: bool,
}

#[derive(Debug, Deserialize)]
pub struct Size {
    pub width: u32,
    pub height: u32,
}

#[derive(Debug, Deserialize)]
pub struct TenantLogo {
    pub id: String,
    pub url: String,
    pub size: Size,
}

#[derive(
    Debug, Deserialize, Serialize, Clone, PartialEq, Eq, PartialOrd, Ord, Copy,
)]
pub enum TenantDomainType {
    #[serde(rename = "managed")]
    Managed,
    #[serde(rename = "external")]
    External,
    #[serde(rename = "subdomain")]
    Subdomain,
    #[serde(rename = "fallback")]
    Fallback,
}

#[derive(Debug, Deserialize)]
pub struct TenantDomain {
    pub host: String,
    #[serde(rename = "type")]
    pub domain_type: TenantDomainType,
}

#[derive(Debug, Deserialize)]
pub struct TenantResponse {
    pub id: String,
    pub name: String,
    pub subdomain: Option<String>,
    pub logo: Option<TenantLogo>,
    pub domains: Vec<TenantDomain>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub enum ApplicationType {
    #[serde(rename = "ios")]
    Ios,
}

#[derive(Debug, Serialize)]
pub struct ApplicationRequest {
    pub name: String,
    pub description: Option<String>,
    pub r#type: ApplicationType,
    /// This is currently only required when `type` is `ios`. But since that's the only type
    /// we support right now, we're making it required here.
    pub ios_bundle_id: String,
    pub is_new_project: bool,
}

#[derive(Debug, Deserialize, Clone)]
pub struct ApplicationIosConfig {
    pub bundle_id: String,
    pub app_id: Option<String>,
    pub team_id: Option<String>,
}

#[derive(Debug, Deserialize, Clone)]
pub struct ApplicationResponse {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub r#type: ApplicationType,
    pub tenant_id: String,
    /// Will always be present when `type` is `ios`.
    pub ios: Option<ApplicationIosConfig>,
}

#[derive(Debug, Deserialize)]
pub struct ApplicationCollectionResponse {
    pub data: Vec<ApplicationResponse>,
}
