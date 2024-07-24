use std::path::{Path, PathBuf};
use std::process::{exit, Command};
use std::{error::Error, fs};

use convert_case::{Case, Casing};
use inquire::Confirm;

use crate::{
    project_generator::{renderer, templates},
    types::api::{ApplicationResponse, TenantResponse},
};

pub fn generate_xcode_project<'a>(
    project_dir: &PathBuf,
    tenant: TenantResponse,
    application: ApplicationResponse,
) -> Result<PathBuf, Box<dyn Error>> {
    let app_name = application.name;
    let camel_name = app_name.to_case(Case::UpperCamel);
    let bundle_id = application.ios.unwrap().bundle_id;

    let target_dir = project_dir.join(app_name.clone());

    if project_dir.exists() {
        let result =
            Confirm::new("Project directory already exists. Overwrite?")
                .with_help_message(
                    "If you choose not to proceed, the program will exit.",
                )
                .with_default(false)
                .prompt()?;

        if !result {
            exit(1);
        }

        fs::remove_dir_all(&project_dir)?;
    }

    create_project_structure(&target_dir)?;

    let globals = liquid::object!({
        "app": {
            "id": application.id,
            "name": app_name,
            "camel_name": camel_name,
            "bundle_id": bundle_id,
            "deployment_target": "17.0",
        },
        "tenant": {
            "id": tenant.id,
            "name": tenant.name,
        }
    });

    create_project_files(tenant, &target_dir, &camel_name, &globals)?;

    let project_yaml = renderer::render_template(
        &templates::get_project_yaml_template(),
        &globals,
    )
    .unwrap();

    run_xcodegen(&project_dir, &project_yaml)?;

    install_spm_dependencies(&project_dir)?;

    Ok(target_dir)
}

fn create_project_structure(
    target_path: &PathBuf,
) -> Result<(), Box<dyn Error>> {
    fs::create_dir_all(target_path)?;

    fs::create_dir_all(target_path.join("Assets.xcassets"))?;
    fs::create_dir_all(
        target_path.join("Assets.xcassets/AccentColor.colorset"),
    )?;
    fs::create_dir_all(target_path.join("Assets.xcassets/AppIcon.appiconset"))?;

    fs::create_dir_all(
        target_path.join("Preview Content/Preview Assets.xcassets"),
    )?;

    Ok(())
}

fn create_project_files(
    tenant: TenantResponse,
    target_path: &PathBuf,
    camel_app_name: &str,
    globals: &liquid::Object,
) -> Result<(), Box<dyn Error>> {
    let app_swift_yaml = renderer::render_template(
        &templates::get_app_swift_template(),
        &globals,
    )
    .unwrap();

    let app_content_view_yaml = renderer::render_template(
        &templates::get_content_view_swift_template(),
        &globals,
    )
    .unwrap();

    create_entitlements_files(tenant, &target_path)?;
    create_asset_catalog(&target_path, &globals)?;

    let preview_assets_json =
        renderer::render_template(&templates::get_assets_json(), &globals)
            .unwrap();

    let app_path = target_path.join(format!("{}App.swift", camel_app_name));
    let content_view_path = target_path.join("ContentView.swift");
    let preview_assets_path = target_path
        .join("Preview Content/Preview Assets.xcassets/Contents.json");

    fs::write(app_path, app_swift_yaml)?;
    fs::write(content_view_path, app_content_view_yaml)?;
    fs::write(preview_assets_path, preview_assets_json)?;

    Ok(())
}

fn create_entitlements_files(
    tenant: TenantResponse,
    target_path: &PathBuf,
) -> Result<(), Box<dyn Error>> {
    // Put the domains in order by priority that they appear in the Apple entitlements
    // file. This is done by looking at the order of the domain type enum cases.
    let mut domains = tenant.domains;
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

    let debug_params = liquid::object!({
        "entitlements": {
            "aps_environment": "development",
            "associated_domains": debug_web_credential_hosts.join("\n"),
        },
    });

    let release_params = liquid::object!({
        "entitlements": {
            "aps_environment": "production",
            "associated_domains": release_web_credential_hosts.join("\n"),
        },
    });

    // development,
    // <string>webcredentials:parra-public-demo.parra.io?mode=developer</string>
    // <string>webcredentials:tenant-201cbcf0-b5d6-4079-9e4d-177ae04cc9f4.parra.io?mode=developer</string>
    // properties:
    //     com.apple.developer.aps-environment: development
    //     com.apple.developer.associated-domains: {{ app.debug_associated_domains }}
    // properties:
    //     com.apple.developer.aps-environment: development
    //     com.apple.developer.associated-domains: {{ app.release_associated_domains }}

    let debug_entitlements_yaml = renderer::render_template(
        &templates::get_entitlements_xml(),
        &debug_params,
    )
    .unwrap();

    let release_entitlements_yaml = renderer::render_template(
        &templates::get_entitlements_xml(),
        &release_params,
    )
    .unwrap();

    let debug_entitlements_path =
        target_path.join("Entitlements-debug.entitlements");
    let release_entitlements_path =
        target_path.join("Entitlements-release.entitlements");

    fs::write(debug_entitlements_path, debug_entitlements_yaml)?;
    fs::write(release_entitlements_path, release_entitlements_yaml)?;

    Ok(())
}

fn create_asset_catalog(
    target_path: &PathBuf,
    globals: &liquid::Object,
) -> Result<(), Box<dyn Error>> {
    let assets_json =
        renderer::render_template(&templates::get_assets_json(), &globals)
            .unwrap();

    let accent_color_json = renderer::render_template(
        &templates::get_accent_color_json(),
        &globals,
    )
    .unwrap();

    let app_icon_json =
        renderer::render_template(&templates::get_app_icon_json(), &globals)
            .unwrap();

    let assets_path = target_path.join("Assets.xcassets/Contents.json");
    let accent_color_path =
        target_path.join("Assets.xcassets/AccentColor.colorset/Contents.json");
    let app_icon_path =
        target_path.join("Assets.xcassets/AppIcon.appiconset/Contents.json");

    fs::write(assets_path, assets_json)?;
    fs::write(accent_color_path, accent_color_json)?;
    fs::write(app_icon_path, app_icon_json)?;

    Ok(())
}

fn run_xcodegen(
    project_path: &PathBuf,
    template: &str,
) -> Result<(), Box<dyn Error>> {
    let tmp_project_yaml_path = Path::new("/tmp/parra_project.yml");
    fs::write(tmp_project_yaml_path, template)?;

    let result = Command::new("xcodegen")
        .arg("--spec")
        .arg(tmp_project_yaml_path.to_str().unwrap())
        .arg("--project")
        .arg(project_path.to_str().unwrap().to_owned())
        .arg("--project-root")
        .arg(project_path.to_str().unwrap().to_owned())
        .output();

    match result {
        Ok(output) => {
            if output.status.success() {
                fs::remove_file(tmp_project_yaml_path)?;

                return Ok(());
            } else {
                let error = String::from_utf8_lossy(&output.stderr);
                eprintln!("Error  executing command: {}", error);
                exit(1);
            }
        }
        Err(error) => {
            eprintln!("Error generating project: {}", error);
            exit(1);
        }
    }
}

fn install_spm_dependencies(path: &PathBuf) -> Result<(), Box<dyn Error>> {
    Command::new("xcodebuild")
        .arg("-resolvePackageDependencies")
        .current_dir(path)
        .output()?;

    Ok(())
}
