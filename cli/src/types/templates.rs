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
    /// Expected to be ready to be inserted into a plist. Should be
    /// newline delimited with each entry wrapped in <string></string>
    pub associated_domains: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AppEntitlementSchemes {
    pub debug: AppEntitlementInfo,
    pub release: AppEntitlementInfo,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct CodeSigningConfig {
    pub identity: String,
    pub required: String,
    pub allowed: String,
    pub style: String,
    pub profile_specifier: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct CodeSigningConfigs {
    pub debug: CodeSigningConfig,
    pub release: CodeSigningConfig,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AppContextInfo {
    pub id: String,
    pub name: AppNameInfo,
    pub bundle_id: String,
    pub deployment_target: String,
    pub entitlements: AppEntitlementSchemes,
    pub code_sign: CodeSigningConfigs,
    pub team_id: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct TenantContextInfo {
    pub id: String,
    pub name: String,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct SdkContextInfo {
    pub version: String,
}

/// In order to be able to effectively recycle logic between the sample app
/// and project generator, this object needs to contain a union of all fields
/// required by both these use cases.
#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct ProjectContext {
    pub app: AppContextInfo,
    pub tenant: TenantContextInfo,
    pub sdk: SdkContextInfo,
}
