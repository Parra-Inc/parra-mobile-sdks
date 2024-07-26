use std::path::PathBuf;

use std::error::Error;
use std::fs::read_to_string;

use liquid::Object;

use crate::project_generator::{renderer, templates};
use crate::types::templates::{
    AppContextInfo, AppNameInfo, CodeSigningConfig, CodeSigningConfigs,
    ProjectContext, SdkContextInfo,
};

pub fn generate_project_from_template(
    output_dir: &PathBuf,
    template_dir: &PathBuf,
    ctx: ProjectContext,
    is_debug: bool,
) -> Result<(), Box<dyn Error>> {
    // 1. Load template
    // 2. Load package per debug flag
    // 3. Merge templates
    // 4. Liquid
    // 5. Create output directory
    // 6. Copy template dir, less yml files into output dir
    // 7. xcodegen

    let template = read_to_string(template_dir)?;
    let package_template: String = if is_debug {
        read_to_string(template_dir.join("package_local.yml"))?
    } else {
        read_to_string(template_dir.join("package_remote.yml"))?
    };

    let mut full_template = String::new();
    full_template.push_str(&template);
    full_template.push_str("\n");
    full_template.push_str(&package_template);

    let context = ProjectContext {
        app: AppContextInfo {
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
                },
                release: CodeSigningConfig {
                    identity: "Apple Distribution".to_owned(),
                    required: "YES".to_owned(),
                    allowed: "YES".to_owned(),
                },
            },
            team_id: "6D44Q764PG".to_owned(),
        },
        sdk: SdkContextInfo {
            version: "0.1.20".to_owned(),
        },
    };

    let globals = liquid::to_object(&context)?;
    let project_yaml = renderer::render_template(&full_template, &globals)?;

    println!("Project yaml:\n{}", project_yaml);

    Ok(())
}
