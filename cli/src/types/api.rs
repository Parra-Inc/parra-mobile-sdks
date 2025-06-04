use std::collections::HashMap;

use serde::{Deserialize, Serialize};

use crate::types::theme::ResolvedTheme;

use super::auth::Credential;

#[allow(dead_code)]
#[derive(Debug, Deserialize, Clone)]
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
    pub credential: Credential,
    pub user: UserResponse,
}

#[derive(Debug, Serialize)]
pub struct TenantRequest {
    pub name: String,
    pub is_test: bool,
}

#[derive(Debug, Serialize)]
pub struct EventRequest<'a> {
    pub name: String,
    pub created_at: String,
    pub metadata: HashMap<&'a str, &'a str>,
}

#[derive(Debug, Serialize)]
pub struct SessionRequest<'a> {
    pub events: Vec<EventRequest<'a>>,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct Size {
    pub width: u32,
    pub height: u32,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct Icon {
    pub id: String,
    pub url: String,
    pub size: Size,
}

#[derive(
    Debug, Deserialize, Serialize, Clone, PartialEq, PartialOrd, Eq, Ord, Copy,
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

#[derive(Debug, Deserialize, Clone)]
pub struct TenantDomain {
    pub host: String,
    #[serde(rename = "type")]
    pub domain_type: TenantDomainType,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize, Clone)]
pub struct TenantResponse {
    pub id: String,
    pub name: String,
    pub subdomain: Option<String>,
    pub logo: Option<Icon>,
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

#[allow(dead_code)]
#[derive(Debug, Deserialize, Clone)]
pub struct ApplicationIosConfig {
    pub bundle_id: String,
    pub app_id: Option<String>,
    pub team_id: Option<String>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize, Clone)]
pub struct ApplicationResponse {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub r#type: String,
    pub tenant_id: String,
    /// Will always be present when `type` is `ios`.
    pub ios: Option<ApplicationIosConfig>,
    pub icon: Option<Icon>,
}

#[derive(Debug, Deserialize)]
pub struct ApplicationCollectionResponse {
    pub data: Vec<ApplicationResponse>,
}

#[derive(Debug, Serialize)]
pub struct EmptyRequest {}

#[derive(Debug, Deserialize)]
pub struct EmptyResponse {}

#[derive(Debug, Serialize)]
pub struct BootstrapRequest {
    pub template: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppTabDescriptor {
    pub name: String,
    pub sf_symbol: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppTabEmptyStateCta {
    pub title: String,
    pub url: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppTabEmptyState {
    pub title: String,
    pub subtitle: Option<String>,
    pub sf_symbol: Option<String>,
    pub cta: Option<AppTabEmptyStateCta>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppShopTabShopifyConfiguration {
    pub domain: String,
    #[serde(rename = "api_key")]
    pub api_key: String,
    #[serde(rename = "discount_code")]
    pub discount_code: Option<String>,
    #[serde(rename = "attribution_source")]
    pub attribution_source: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub enum AppTabType {
    Sample,
    Feed,
    Shop,
    Settings,
    Webview,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Copy)]
pub enum AppFeedContentType {
    #[serde(rename = "videos")]
    Videos,
    #[serde(rename = "episodes")]
    Episode,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppSampleTabData {
    pub title: String,
    pub tab: AppTabDescriptor,
    #[serde(rename = "empty_state")]
    pub empty_state: Option<AppTabEmptyState>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppFeedTabData {
    pub title: String,
    pub tab: AppTabDescriptor,
    #[serde(rename = "feed_id")]
    pub feed_id: Option<String>,
    pub content_type: Option<AppFeedContentType>,
    #[serde(rename = "empty_state")]
    pub empty_state: Option<AppTabEmptyState>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppShopTabData {
    pub title: String,
    pub tab: AppTabDescriptor,
    pub shopify: Option<AppShopTabShopifyConfiguration>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppSettingsTabData {
    pub title: String,
    pub tab: AppTabDescriptor,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppWebViewTabData {
    pub title: String,
    pub tab: AppTabDescriptor,
    pub url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(tag = "type")]

pub enum AppTab {
    #[serde(rename = "sample")]
    AppSampleTab(AppSampleTabData),
    #[serde(rename = "feed")]
    AppFeedTab(AppFeedTabData),
    #[serde(rename = "shop")]
    AppShopTab(AppShopTabData),
    #[serde(rename = "settings")]
    AppSettingsTab(AppSettingsTabData),
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub enum AppTemplate {
    Default,
    Podcast,
    RevenueCat,
    ShopifyStorefront,
    YC,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppBootstrapTemplate {
    pub tabs: Vec<AppTab>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppBootstrapResponseBody {
    #[serde(rename = "tenant_id")]
    pub tenant_id: String,
    #[serde(rename = "application_id")]
    pub application_id: String,
    #[serde(rename = "template")]
    pub template: AppTemplate,
    pub tabs: Vec<AppTab>,
    pub themes: Vec<ResolvedTheme>,
}
