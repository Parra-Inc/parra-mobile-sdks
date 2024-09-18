use std::path::{Path, PathBuf};
use std::process::{exit, Command};
use std::{error::Error, fs, io};

use image::imageops::FilterType;
use image::ImageFormat;
use inquire::validator::{MaxLengthValidator, MinLengthValidator};
use inquire::{Confirm, Text};
use liquid::model::Value;
use liquid::Object;
use reqwest::get;

use crate::api;
use crate::project_generator::renderer;
use crate::types::api::Icon;
use crate::types::templates::{CliInput, ProjectContext};

pub async fn generate_xcode_project(
    project_dir: &PathBuf,
    template_app_dir: &PathBuf,
    template: &str,
    context: &ProjectContext,
    prompt_for_override: bool,
) -> Result<PathBuf, Box<dyn Error>> {
    let mut globals = liquid::to_object(&context)?;

    if let Some(input_config) = &context.config.cli_input {
        if !input_config.inputs.is_empty() {
            let mut liquid_map = Object::new();

            for input in <Vec<CliInput> as Clone>::clone(&input_config.inputs)
                .into_iter()
            {
                let mut text_input = Text::new(&input.prompt)
                    .with_validator(MaxLengthValidator::new(input.max_length));

                text_input = if input.required {
                    text_input.with_validator(MinLengthValidator::new(
                        input.min_length,
                    ))
                } else {
                    text_input
                };

                text_input = if let Some(help_message) = &input.help_message {
                    text_input.with_help_message(&help_message.as_str())
                } else {
                    text_input
                };

                text_input =
                    if let Some(default_message) = &input.default_message {
                        text_input.with_default(&default_message.as_str())
                    } else {
                        text_input
                    };

                let user_input = text_input.prompt()?;
                let trimmed = user_input.trim().trim_matches('"');

                let value = if trimmed.is_empty() {
                    input.default.unwrap_or("".into())
                } else {
                    trimmed.into()
                };

                liquid_map.insert(input.key.into(), Value::scalar(value));
            }

            globals.insert(
                <std::string::String as Clone>::clone(&input_config.name)
                    .into(),
                Value::Object(liquid_map),
            );
        }
    }

    let camel_app_name = context.app.name.upper_camel.clone();
    let target_dir = project_dir.join(camel_app_name);

    if project_dir.exists() {
        if prompt_for_override {
            let result =
                Confirm::new("Project directory already exists. Overwrite?")
                    .with_help_message(
                        "If you choose not to proceed, the program will exit.",
                    )
                    .with_default(false)
                    .prompt()?;

            if !result {
                exit(1);
            } else {
                api::report_event("cli_bootstrap_project_overridden", None)
                    .await?;
            }
        }

        fs::remove_dir_all(&project_dir)?;
    }

    copy_dir_all(template_app_dir, &target_dir)?;

    println!("Generating project...");

    renderer::render_templates_in_dir(&target_dir, &globals)?;

    let rendered_project_template =
        renderer::render_template(&template, &globals)?;

    api::report_event("cli_bootstrap_template_rendered", None).await?;

    run_xcodegen(&project_dir, &rendered_project_template)?;

    api::report_event("cli_bootstrap_project_generated", None).await?;

    if let Some(icon) = &context.app.icon {
        match replace_app_icon(&target_dir, icon).await {
            Ok(_) => {}
            Err(err) => {
                eprintln!("Error downloading app icon. Using default instead. Error: {}", err);
            }
        }
    }

    install_spm_dependencies(&project_dir)?;

    api::report_event("cli_bootstrap_project_packages_installed", None).await?;

    return Ok(target_dir);
}

fn copy_dir_all(src: &PathBuf, dst: impl AsRef<Path>) -> io::Result<()> {
    fs::create_dir_all(&dst)?;

    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;

        if ty.is_dir() {
            copy_dir_all(&entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }

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

async fn replace_app_icon(
    project_path: &PathBuf,
    icon: &Icon,
) -> Result<(), Box<dyn Error>> {
    let output_path =
        project_path.join("Assets.xcassets/AppIcon.appiconset/app-icon.png");

    println!("Downloading app icon...");

    // Download the image
    let response = get(&icon.url).await?;
    let bytes = response.bytes().await?;

    // Load the image
    let image = image::load_from_memory(&bytes)?;

    let sized_image = if icon.size.width == 1024 && icon.size.height == 1024 {
        image
    } else {
        // Resize the image to 1024x1024 using Lanczos3 filter for high-quality resizing
        image.resize(1024, 1024, FilterType::Lanczos3)
    };

    // Save the resized image to a file
    sized_image.save_with_format(output_path, ImageFormat::Png)?;

    Ok(())
}

fn install_spm_dependencies(path: &PathBuf) -> Result<(), Box<dyn Error>> {
    Command::new("xcodebuild")
        .arg("-resolvePackageDependencies")
        .current_dir(path)
        .output()?;

    Ok(())
}
