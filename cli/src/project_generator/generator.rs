use std::path::{Path, PathBuf};
use std::process::{exit, Command};
use std::{error::Error, fs, io};

use inquire::validator::{MaxLengthValidator, MinLengthValidator};
use inquire::{Confirm, Text};
use liquid::model::Value;
use liquid::Object;

use crate::project_generator::renderer;
use crate::types::templates::{CliInput, ProjectContext};

pub fn generate_xcode_project(
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
                let value = if user_input.trim().is_empty() {
                    input.default.unwrap_or("".into())
                } else {
                    user_input
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
            }
        }

        fs::remove_dir_all(&project_dir)?;
    }

    copy_dir_all(template_app_dir, &target_dir)?;

    renderer::render_templates_in_dir(&target_dir, &globals)?;

    let rendered_project_template =
        renderer::render_template(&template, &globals)?;

    run_xcodegen(&project_dir, &rendered_project_template)?;

    install_spm_dependencies(&project_dir)?;

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

fn install_spm_dependencies(path: &PathBuf) -> Result<(), Box<dyn Error>> {
    Command::new("xcodebuild")
        .arg("-resolvePackageDependencies")
        .current_dir(path)
        .output()?;

    Ok(())
}
