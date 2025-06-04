use serde::{Deserialize, Serialize};

use crate::types::{
    api::{
        AppBootstrapResponseBody, AppFeedContentType, AppFeedTabData,
        AppSampleTabData, AppSettingsTabData, AppShopTabData, AppTab,
        AppTabDescriptor, AppTabEmptyState,
    },
    theme::ResolvedTheme,
};

use super::api::Icon;

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct CliInput {
    #[serde(default = "default_required")]
    pub required: bool,

    pub prompt: String,
    pub help_message: Option<String>,
    pub default_message: Option<String>,
    pub default: Option<String>,
    pub key: String,

    #[serde(default = "default_min_length")]
    pub min_length: usize,

    #[serde(default = "default_max_length")]
    pub max_length: usize,
}

fn default_min_length() -> usize {
    return 1;
}

fn default_max_length() -> usize {
    return 255;
}

fn default_required() -> bool {
    return true;
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct InputConfig {
    pub name: String,
    pub inputs: Vec<CliInput>,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct TemplateConfig {
    pub cli_input: Option<InputConfig>,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct AppNameInfo {
    pub raw: String,
    pub kebab: String,
    pub upper_camel: String,
    pub display_name: String,
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
    pub build_number: String,
    pub marketing_version: String,
    pub name: AppNameInfo,
    pub bundle_id: String,
    pub deployment_target: String,
    pub entitlements: AppEntitlementSchemes,
    pub code_sign: CodeSigningConfigs,
    pub team_id: String,
    pub icon: Option<Icon>,
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

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct TabInfo {
    pub name: String,
    pub sf_symbol: String,
    pub empty_state: Option<AppTabEmptyState>,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct TabsInfo {
    pub sample: AppSampleTabData,
    pub episodes: AppFeedTabData,
    pub videos: AppFeedTabData,
    pub shop: AppShopTabData,
    pub settings: AppSettingsTabData,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct ThemeInfo {
    pub default: Option<ResolvedTheme>,
    pub dark: Option<ResolvedTheme>,
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct TemplateInfo {
    pub name: String,
    pub tabs: TabsInfo,
    pub theme: ThemeInfo,
}

impl TemplateInfo {
    fn find_sample_tab(
        bootstrap_response: Option<&AppBootstrapResponseBody>,
    ) -> Option<&AppSampleTabData> {
        if bootstrap_response.is_none() {
            return None;
        }

        bootstrap_response
            .as_ref()
            .unwrap()
            .tabs
            .iter()
            .find_map(|tab| {
                if let AppTab::AppSampleTab(data) = tab {
                    Some(data)
                } else {
                    None
                }
            })
    }

    fn find_feed_tab(
        bootstrap_response: Option<&AppBootstrapResponseBody>,
        content_type: AppFeedContentType,
    ) -> Option<&AppFeedTabData> {
        if bootstrap_response.is_none() {
            return None;
        }

        bootstrap_response
            .as_ref()
            .unwrap()
            .tabs
            .iter()
            .find_map(|tab| {
                if let AppTab::AppFeedTab(data) = tab {
                    if data.content_type == Some(content_type) {
                        Some(data)
                    } else {
                        None
                    }
                } else {
                    None
                }
            })
    }

    fn find_shop_tab(
        bootstrap_response: Option<&AppBootstrapResponseBody>,
    ) -> Option<&AppShopTabData> {
        if bootstrap_response.is_none() {
            return None;
        }

        bootstrap_response
            .as_ref()
            .unwrap()
            .tabs
            .iter()
            .find_map(|tab| {
                if let AppTab::AppShopTab(data) = tab {
                    Some(data)
                } else {
                    None
                }
            })
    }

    fn find_settings_tab(
        bootstrap_response: Option<&AppBootstrapResponseBody>,
    ) -> Option<&AppSettingsTabData> {
        if bootstrap_response.is_none() {
            return None;
        }

        bootstrap_response
            .as_ref()
            .unwrap()
            .tabs
            .iter()
            .find_map(|tab| {
                if let AppTab::AppSettingsTab(data) = tab {
                    Some(data)
                } else {
                    None
                }
            })
    }

    fn find_themes(
        bootstrap_response: Option<&AppBootstrapResponseBody>,
    ) -> (Option<ResolvedTheme>, Option<ResolvedTheme>) {
        if bootstrap_response.is_none() {
            return (None, None);
        }

        let default_theme =
            bootstrap_response.as_ref().unwrap().themes.iter().find_map(
                |theme| {
                    if theme.is_default {
                        Some(theme)
                    } else {
                        None
                    }
                },
            );

        let dark_theme =
            bootstrap_response.as_ref().unwrap().themes.iter().find_map(
                |theme| if theme.is_dark { Some(theme) } else { None },
            );

        (default_theme.cloned(), dark_theme.cloned())
    }

    pub fn with_bootstrap_response(
        template_name: &str,
        bootstrap_response: Option<&AppBootstrapResponseBody>,
    ) -> TemplateInfo {
        let default_sample_tab = AppSampleTabData {
            title: "Sample".to_string(),
            tab: AppTabDescriptor {
                name: "Sample".to_string(),
                sf_symbol: "app.dashed".to_string(),
            },
            empty_state: None,
        };

        let default_episodes_tab = AppFeedTabData {
            title: "Episodes".to_string(),
            feed_id: None,
            content_type: Some(AppFeedContentType::Episode),
            empty_state: None,
            tab: AppTabDescriptor {
                name: "Episodes".to_string(),
                sf_symbol: "rectangle.stack.badge.play".to_string(),
            },
        };

        let default_videos_tab = AppFeedTabData {
            title: "Videos".to_string(),
            feed_id: None,
            content_type: Some(AppFeedContentType::Videos),
            empty_state: None,
            tab: AppTabDescriptor {
                name: "Videos".to_string(),
                sf_symbol: "rectangle.stack".to_string(),
            },
        };

        let default_shop_tab = AppShopTabData {
            title: "Shop".to_string(),
            shopify: None,
            tab: AppTabDescriptor {
                name: "Shop".to_string(),
                sf_symbol: "cart".to_string(),
            },
        };

        let default_settings_tab = AppSettingsTabData {
            title: "Settings".to_string(),
            tab: AppTabDescriptor {
                name: "Settings".to_string(),
                sf_symbol: "gearshape.fill".to_string(),
            },
        };

        let sample_tab = Self::find_sample_tab(bootstrap_response)
            .unwrap_or(&default_sample_tab);

        let episodes_tab = Self::find_feed_tab(
            bootstrap_response,
            AppFeedContentType::Episode,
        )
        .unwrap_or(&default_episodes_tab);

        let videos_tab =
            Self::find_feed_tab(bootstrap_response, AppFeedContentType::Videos)
                .unwrap_or(&default_videos_tab);

        let shop_tab = Self::find_shop_tab(bootstrap_response)
            .unwrap_or(&default_shop_tab);

        let settings_tab = Self::find_settings_tab(bootstrap_response)
            .unwrap_or(&default_settings_tab);

        let (default_theme, dark_theme) = Self::find_themes(bootstrap_response);

        TemplateInfo {
            name: template_name.to_string(),
            tabs: TabsInfo {
                sample: sample_tab.clone(),
                episodes: episodes_tab.clone(),
                videos: videos_tab.clone(),
                shop: shop_tab.clone(),
                settings: settings_tab.clone(),
            },
            theme: ThemeInfo {
                default: default_theme,
                dark: dark_theme,
            },
        }
    }
}

/// In order to be able to effectively recycle logic between the sample app
/// and project generator, this object needs to contain a union of all fields
/// required by both these use cases.
#[derive(Debug, Deserialize, Clone, Serialize)]
pub struct ProjectContext {
    pub app: AppContextInfo,
    pub tenant: TenantContextInfo,
    pub sdk: SdkContextInfo,
    pub config: TemplateConfig,
    pub template: TemplateInfo,
}
