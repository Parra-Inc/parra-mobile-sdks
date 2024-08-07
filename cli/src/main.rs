use std::error::Error;
mod api;
mod arg_parser;
mod auth;
mod commands;
mod constants;
mod dependencies;
mod project_generator;
mod types;

use constants::sample::{
    PARRA_LOCAL_SAMPLE_NAME, PARRA_REMOTE_SAMPLE_NAME,
    PARRA_SAMPLE_TEMPLATE_PREFIX,
};

use crate::arg_parser::Command;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let cli = arg_parser::parse_args();

    match cli.command {
        Command::Bootstrap(bootstrap_args) => {
            if bootstrap_args
                .template_name
                .starts_with(PARRA_SAMPLE_TEMPLATE_PREFIX)
            {
                let sample_name = bootstrap_args
                    .template_name
                    .strip_prefix(PARRA_SAMPLE_TEMPLATE_PREFIX)
                    .unwrap();

                if ![PARRA_LOCAL_SAMPLE_NAME, PARRA_REMOTE_SAMPLE_NAME]
                    .contains(&sample_name)
                {
                    return Err(format!(
                        "Unknown Parra sample app name provided: {}",
                        sample_name
                    )
                    .into());
                }

                commands::bootstrap::execute_sample_bootstrap(
                    bootstrap_args.project_path,
                    sample_name == PARRA_LOCAL_SAMPLE_NAME,
                )
                .await?;
            } else {
                commands::bootstrap::execute_bootstrap(
                    bootstrap_args.application_id,
                    bootstrap_args.workspace_id,
                    bootstrap_args.project_path,
                    bootstrap_args.template_name,
                )
                .await?
            }
        }
        Command::Login(_) => {
            commands::login::execute_login().await;
        }
        Command::Logout(_) => commands::logout::execute_logout(),
    }

    Ok(())
}
