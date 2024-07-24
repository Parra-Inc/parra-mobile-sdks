use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AppNameInfo {
    pub raw: String,
    pub kebab: String,
    pub upper_camel: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AppEntitlementInfo {
    pub aps_environment: String,
    pub associated_domains: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AppEntitlementSchemes {
    pub debug: AppEntitlementInfo,
    pub release: AppEntitlementInfo,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AppTemplateInfo {
    pub id: String,
    pub name: AppNameInfo,
    pub bundle_id: String,
    pub deployment_target: String,
    pub entitlements: AppEntitlementSchemes,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct TenantTemplateInfo {
    pub id: String,
    pub name: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct ProjectTemplate {
    pub app: AppTemplateInfo,
    pub tenant: TenantTemplateInfo,
}
