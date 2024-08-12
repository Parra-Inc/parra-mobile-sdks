use crate::constants::built::{self, built_info};
use crate::dependencies::DerivedDependency;
use crate::types::api::{
    ApplicationResponse, TenantDomain, TenantDomainType, TenantResponse,
};
use crate::types::dependency::SemanticVersion;
use crate::types::templates::{
    AppContextInfo, AppEntitlementInfo, AppEntitlementSchemes, AppNameInfo,
    CodeSigningConfig, CodeSigningConfigs, ProjectContext, SdkContextInfo,
    TenantContextInfo,
};
use crate::{api, dependencies, project_generator};
use convert_case::{Case, Casing};
use git2::Repository;
use inquire::validator::{MaxLengthValidator, MinLengthValidator, Validation};
use inquire::{Confirm, InquireError, Select, Text};
use regex::Regex;
use slugify::slugify;
use std::env::{self};
use std::error::Error;
use std::fmt::Display;
use std::fs::read_to_string;
use std::path::{Path, PathBuf};
use std::process::{exit, Command};
use std::str::FromStr;

static MIN_XCODE_VERSION: SemanticVersion = SemanticVersion {
    major: 15,
    minor: 3,
    patch: 0,
};

static DESIRED_XCODE_VERSION: SemanticVersion = SemanticVersion {
    major: 15,
    minor: 4,
    patch: 0,
};

static DESIRED_IOS_RUNTIME_VERSION: SemanticVersion = SemanticVersion {
    major: 17,
    minor: 5,
    patch: 0,
};

impl Display for TenantResponse {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} ({})", self.name, self.id)
    }
}

impl Display for ApplicationResponse {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if let Some(ios) = &self.ios {
            write!(f, "{} ({})", self.name, ios.bundle_id)
        } else {
            write!(f, "{}", self.name)
        }
    }
}

impl Display for SemanticVersion {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.{}.{}", self.major, self.minor, self.patch)
    }
}

fn get_local_template(
    template_dir: &PathBuf,
    use_local_packages: bool,
) -> Result<String, Box<dyn Error>> {
    let project_template_path = template_dir.join("project.yml");
    let template = read_to_string(project_template_path)?;

    let package_template: String = if use_local_packages {
        read_to_string(template_dir.join("package_local.yml"))?
    } else {
        read_to_string(template_dir.join("package_remote.yml"))?
    };

    Ok(format!("{}\n{}", template, package_template))
}

async fn get_remote_template(
    template_name: &str,
) -> Result<(String, PathBuf), Box<dyn Error>> {
    let version = built_info::PKG_VERSION;

    let tmp_dir_output = Command::new("mktemp")
        .arg("-d")
        .output()
        .expect("Error creating temporary directory");
    let tmp_dir = String::from_utf8(tmp_dir_output.stdout)?.trim().to_string();

    Command::new("git")
        .arg("clone")
        .arg("--no-checkout")
        .arg("--depth=1")
        .arg("--filter=tree:0")
        .arg("https://github.com/Parra-Inc/parra-mobile-sdks")
        .arg(tmp_dir.clone())
        .output()
        .expect("Failed to clone template repo");

    Command::new("git")
        .arg("sparse-checkout")
        .arg("set")
        .arg("--no-cone")
        .arg("templates")
        .current_dir(tmp_dir.clone())
        .output()
        .expect("Failed to perform template sparse checkout");

    Command::new("git")
        .arg("fetch")
        .arg("origin")
        .arg("tag")
        .arg(version)
        // --no-tags ensures no additional tags are pulled.
        .arg("--no-tags")
        .current_dir(tmp_dir.clone())
        .output()
        .expect("Failed to perform template tag fetch");

    Command::new("git")
        .arg("checkout")
        .arg(format!("tags/{}", version))
        .current_dir(tmp_dir.clone())
        .output()
        .expect("Failed to perform checkout at tag");

    let template_dir =
        Path::new(&tmp_dir).join("templates").join(template_name);

    let template = get_local_template(&template_dir, false)?;
    let app_dir = template_dir.join("App");

    return Ok((template, app_dir));
}

pub async fn execute_sample_bootstrap(
    project_path: Option<String>,
    use_local_packages: bool,
) -> Result<(), Box<dyn Error>> {
    println!("Preparing to generate Parra Sample project. Will link packages locally: {}", use_local_packages);

    let template_dir = get_template_path("default")?;
    let template_app_dir = template_dir.join("App/");
    // Sample app generation will always use the local template. Even in CI, the template
    // is accessible and should have already been updated for any necessary SDK changes by
    // this point.
    let template = get_local_template(&template_dir, use_local_packages)?;

    let project_dir: PathBuf = if let Some(project_path) = project_path {
        normalized_project_path(Some(project_path), "ParraSample")?
    } else {
        get_sample_path()?
    };

    println!("Will generate sample in: {}", project_dir.display());

    let demo_app_id = "edec3a6c-a375-4a9d-bce8-eb00860ef228";
    let demo_tenant_id = "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4";

    let context: ProjectContext = ProjectContext {
        app: AppContextInfo {
            id: demo_app_id.to_owned(),
            name: AppNameInfo {
                raw: "Parra Demo".to_owned(),
                kebab: "parra-demo".to_owned(),
                upper_camel: "ParraDemo".to_owned(),
            },
            bundle_id: "com.parra.parra-ios-client".to_owned(),
            deployment_target: "17.0".to_owned(),
            code_sign: CodeSigningConfigs {
                debug: CodeSigningConfig {
                    identity: "Apple Development".to_owned(),
                    required: "YES".to_owned(),
                    allowed: "YES".to_owned(),
                    style: "Automatic".to_owned(),
                    profile_specifier: "".to_owned(),
                },
                release: CodeSigningConfig {
                    // Should be Apple Development here too by default.
                    identity: "Apple Development".to_owned(),
                    required: "YES".to_owned(),
                    allowed: "YES".to_owned(),
                    style: "Automatic".to_owned(),
                    profile_specifier: "".to_owned(),
                },
            },
            team_id: "6D44Q764PG".to_owned(),
            entitlements: get_entitlement_schemes(vec![
                TenantDomain {
                    host: "parra-demo.com".to_owned(),
                    domain_type: TenantDomainType::External,
                },
                TenantDomain {
                    host: "parra-public-demo.parra.io".to_owned(),
                    domain_type: TenantDomainType::Subdomain,
                },
                TenantDomain {
                    host: format!("tenant-{}.parra.io", demo_tenant_id)
                        .to_owned(),
                    domain_type: TenantDomainType::Fallback,
                },
            ]),
        },
        sdk: SdkContextInfo {
            version: built::built_info::PKG_VERSION.to_owned(),
        },
        tenant: TenantContextInfo {
            id: demo_tenant_id.to_owned(),
            name: "Parra Inc.".to_owned(),
        },
    };

    let xcode_project_path =
        project_generator::generator::generate_xcode_project(
            &project_dir,
            &template_app_dir,
            &template,
            &context,
            false,
        )?;

    println!(
        "Parra project generated at {}!",
        xcode_project_path.to_str().unwrap()
    );

    Ok(())
}

fn normalized_project_path(
    project_path: Option<String>,
    app_name: &str,
) -> Result<PathBuf, Box<dyn Error>> {
    let kebab_name = app_name.to_case(Case::Kebab);
    let relative_path = get_project_path(project_path, &kebab_name);

    let mut project_path = PathBuf::from_str(&relative_path)?;
    if !project_path.ends_with(&kebab_name) {
        project_path.push(&kebab_name);
    }

    let expanded_path = expand_tilde(&project_path).unwrap();

    return Ok(expanded_path);
}

pub async fn execute_bootstrap(
    application_id: Option<String>,
    workspace_id: Option<String>,
    project_path: Option<String>,
    template_name: String,
) -> Result<(), Box<dyn Error>> {
    let tenant = get_tenant(workspace_id).await?;
    let mut application = get_application(application_id, &tenant).await?;

    // If the app name ends with "App", remove it.
    if application.name.to_lowercase().ends_with("app") {
        application.name =
            application.name.trim_end_matches("app").trim().to_string();
    }

    let expanded_path =
        normalized_project_path(project_path, &application.name)?;

    let (template, template_app_dir) =
        get_remote_template(&template_name).await?;

    let app_name = &application.name;
    let ios_config = application.ios.unwrap();

    println!("Generating project...");

    let context: ProjectContext = ProjectContext {
        app: AppContextInfo {
            id: application.id,
            name: AppNameInfo {
                raw: app_name.to_owned(),
                kebab: app_name.to_case(Case::Kebab),
                upper_camel: app_name.to_case(Case::UpperCamel),
            },
            bundle_id: ios_config.bundle_id,
            deployment_target: "17.0".to_owned(),
            code_sign: CodeSigningConfigs {
                debug: CodeSigningConfig {
                    identity: "".to_owned(),
                    required: "NO".to_owned(),
                    allowed: "NO".to_owned(),
                    style: "Automatic".to_owned(),
                    profile_specifier: "".to_owned(),
                },
                release: CodeSigningConfig {
                    identity: "".to_owned(),
                    required: "NO".to_owned(),
                    allowed: "NO".to_owned(),
                    style: "Automatic".to_owned(),
                    profile_specifier: "".to_owned(),
                },
            },
            team_id: ios_config.team_id.unwrap_or("".to_owned()),
            entitlements: get_entitlement_schemes(tenant.domains),
        },
        sdk: SdkContextInfo {
            version: "0.1.20".to_owned(),
        },
        tenant: TenantContextInfo {
            id: tenant.id,
            name: tenant.name,
        },
    };

    let xcode_project = project_generator::generator::generate_xcode_project(
        &expanded_path,
        &template_app_dir,
        &template,
        &context,
        true,
    )?;

    let xcode_target_dir = &xcode_project;

    println!(
        "Parra project generated at {}!",
        expanded_path.to_str().unwrap()
    );

    let missing = missing_dependencies();
    // If all dependencies are met, open the project. Otherwise, prompt the user to install them,
    // and then open the project on completion.
    if missing.is_empty() {
        open_project(xcode_target_dir)?;
    } else {
        dependencies(missing).await?;

        open_project(xcode_target_dir)?;
    }

    Ok(())
}

fn get_entitlement_schemes(
    allowed_domains: Vec<TenantDomain>,
) -> AppEntitlementSchemes {
    // Put the domains in order by priority that they appear in the Apple entitlements
    // file. This is done by looking at the order of the domain type enum cases.
    let mut domains = allowed_domains;
    domains.sort_by_key(|domain| domain.domain_type);

    let debug_web_credential_hosts: Vec<String> = domains
        .iter()
        .map(|domain| {
            return format!(
                "<string>webcredentials:{}?mode=developer</string>",
                domain.host
            );
        })
        .collect();

    let release_web_credential_hosts: Vec<String> = domains
        .iter()
        .map(|domain| {
            return format!("<string>webcredentials:{}</string>", domain.host);
        })
        .collect();

    return AppEntitlementSchemes {
        debug: AppEntitlementInfo {
            aps_environment: "development".to_owned(),
            associated_domains: debug_web_credential_hosts.join("\n\t\t"),
        },
        release: AppEntitlementInfo {
            aps_environment: "production".to_owned(),
            associated_domains: release_web_credential_hosts.join("\n\t\t"),
        },
    };
}

fn missing_dependencies() -> Vec<DerivedDependency> {
    dependencies::check_for_missing_dependencies(MIN_XCODE_VERSION)
}

async fn dependencies(
    missing: Vec<DerivedDependency>,
) -> Result<(), Box<dyn Error>> {
    if missing.is_empty() {
        return Ok(());
    }

    let confirm_message = if missing
        .contains(&dependencies::DerivedDependency::Xcode)
    {
        "\nWe need to install a few dependencies, including an Xcode update. This might take a few minutes depending on your internet connection. You may be prompted to enter your Apple ID and password in order to download Xcode. Proceed?"
    } else {
        "\nWe need to install a few dependencies first. Proceed?"
    };

    let confirmed_install =
        Confirm::new(confirm_message).with_default(true).prompt()?;

    // Trim the input and check if it's an affirmative response
    if confirmed_install {
        dependencies::install_missing_dependencies(
            DESIRED_XCODE_VERSION,
            DESIRED_IOS_RUNTIME_VERSION,
        );
    } else {
        println!("Please install Xcode version {} or later before opening your new project.", MIN_XCODE_VERSION);

        exit(1)
    }

    Ok(())
}

async fn get_tenant(
    tenant_arg: Option<String>,
) -> Result<TenantResponse, Box<dyn Error>> {
    // The user provided a tenant ID directly.
    if let Some(tenant_id) = tenant_arg {
        return api::get_tenant(&tenant_id).await;
    }

    let tenants = api::get_tenants().await?;

    if tenants.is_empty() {
        return create_new_tenant(false).await;
    }

    let use_existing =
        Confirm::new("Would you like to use an existing workspace?")
            .with_default(true)
            .prompt()?;

    if use_existing {
        let selected_tenant: Result<TenantResponse, InquireError> =
            Select::new("Please select a workspace", tenants).prompt();

        return Ok(selected_tenant?);
    } else {
        return create_new_tenant(true).await;
    }
}

async fn get_application(
    application_arg: Option<String>,
    tenant: &TenantResponse,
) -> Result<ApplicationResponse, Box<dyn Error>> {
    // The user provided a application ID directly.
    if let Some(application_arg) = application_arg {
        return api::get_application(&tenant.id, &application_arg).await;
    }

    let applications = api::paginate_applications(&tenant.id).await?;

    if applications.is_empty() {
        return create_new_application(&tenant).await;
    }

    let use_existing = Confirm::new("Would you like to use an existing application?")
        .with_default(true)
        .with_help_message("We found existing applications that you can use. If you choose not to use them, a new application will be created.")
        .prompt()?;

    if use_existing {
        let selected_application: Result<ApplicationResponse, InquireError> =
            Select::new("Please select an application", applications).prompt();

        match selected_application {
            Ok(application) => return Ok(application),
            Err(error) => Err(error.into()),
        }
    } else {
        return create_new_application(&tenant).await;
    }
}

fn get_project_path(
    project_path_arg: Option<String>,
    app_name: &str,
) -> String {
    if let Some(project_path) = project_path_arg {
        return project_path;
    }

    let default_path = format!("./{}", app_name);
    let default_message = format!("For example: ~/Desktop/{}", app_name);

    let project_path =
        Text::new("Where would you like to create your project?")
            .with_default(&default_path)
            .with_validator(MinLengthValidator::new(1))
            .with_help_message(&default_message)
            .prompt()
            .unwrap();

    return project_path;
}

async fn create_new_tenant(
    others_exist: bool,
) -> Result<TenantResponse, Box<dyn Error>> {
    let message = if others_exist {
        "What would you like to call your workspace?"
    } else {
        "No existing workspaces found. What would you like to call your workspace?"
    };

    let name = Text::new(message)
        .with_validator(MinLengthValidator::new(1))
        .prompt()?;

    return api::create_tenant(&name.trim()).await;
}

async fn create_new_application(
    tenant: &TenantResponse,
) -> Result<ApplicationResponse, Box<dyn Error>> {
    let name = Text::new("What would you like to call your application?")
        .with_validator(MinLengthValidator::new(1))
        .prompt()?;

    let tenant_slug = slugify!(&tenant.name);
    let app_name_slug = slugify!(&name);

    let suggested_bundle_id = format!("com.{}.{}", tenant_slug, app_name_slug);

    let bundle_id = Text::new("What would you like your bundle ID to be?")
        .with_default(&suggested_bundle_id)
        .with_validator(MinLengthValidator::new(5)) // min for x.y.z
        .with_validator(MaxLengthValidator::new(155))
        .with_validator(|input: &str| {
            let re =
                Regex::new(r"^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+){2,}$").unwrap();

            if re.is_match(input) {
                Ok(Validation::Valid)
            } else {
                Ok(Validation::Invalid("The bundle ID string must contain only alphanumeric characters (A–Z, a–z, and 0–9), hyphens (-), and periods (.). Typically, you use a reverse-DNS format for bundle ID strings. Bundle IDs are case-insensitive.".into()))
            }
        })
        .prompt()?;

    let new_application =
        api::create_application(&tenant.id, &name.trim(), &bundle_id.trim())
            .await?;

    return Ok(new_application);
}

fn open_project(path: &PathBuf) -> Result<(), Box<dyn Error>> {
    println!("🚀 Launching project! 🚀");

    let binding = path.to_str().unwrap().to_owned() + ".xcodeproj";

    let full_path: String =
        if !binding.starts_with("/") && !binding.starts_with(".") {
            format!("./{}", binding)
        } else {
            binding
        };
    let path_clone = full_path.clone();

    let xcode_path_output = Command::new("xcrun")
        .arg("xcode-select")
        .arg("--print-path")
        .output()
        .expect("Failed to get Xcode install location");

    let xcode_path = String::from_utf8(xcode_path_output.stdout)?
        .trim()
        .to_string()
        .split(".app")
        .next()
        .unwrap()
        .to_owned()
        + ".app";

    println!("{}", full_path);

    let output = Command::new("open")
        .arg(full_path)
        .arg("-a")
        .arg(xcode_path)
        // .current_dir(path)
        .output()
        .expect("Failed to open project in Xcode");

    if !output.status.success() {
        println!("Couldn't open your project in Xcode automatically. Open your project at: {}", path_clone);
    }

    Ok(())
}

extern crate dirs; // 1.0.4

fn expand_tilde<P: AsRef<Path>>(path_user_input: P) -> Option<PathBuf> {
    let p = path_user_input.as_ref();

    if !p.starts_with("~") {
        return Some(p.to_path_buf());
    }

    if p == Path::new("~") {
        return dirs::home_dir();
    }

    dirs::home_dir().map(|mut h| {
        if h == Path::new("/") {
            // Corner case: `h` root directory;
            // don't prepend extra `/`, just drop the tilde.
            p.strip_prefix("~").unwrap().to_path_buf()
        } else {
            h.push(p.strip_prefix("~/").unwrap());
            h
        }
    })
}

fn get_template_path(template_name: &str) -> Result<PathBuf, Box<dyn Error>> {
    let repo_path = get_repo_root_path()?;
    let relative_path = PathBuf::from(format!("templates/{}/", template_name));
    let full_path = repo_path.join(&relative_path);

    return Ok(full_path);
}

fn get_sample_path() -> Result<PathBuf, Box<dyn Error>> {
    let repo_path = get_repo_root_path()?;
    let relative_path = PathBuf::from("sample/");
    let full_path = repo_path.join(&relative_path);

    println!("Full sample path: {}", full_path.display());

    return Ok(full_path);
}

fn get_repo_root_path() -> Result<PathBuf, Box<dyn Error>> {
    let current_dir = env::current_dir()?;
    let repo = Repository::discover(&current_dir)?;
    let repo_path = repo
        .workdir()
        .ok_or("Could not find the working directory for the repo.")?;

    return Ok(repo_path.to_path_buf());
}
