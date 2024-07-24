use std::error::Error;
mod api;
mod arg_parser;
mod auth;
mod commands;
mod dependencies;
mod project_generator;
mod types;

use crate::arg_parser::Commands;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let cli = arg_parser::parse_args();

    match cli.command {
        Commands::Bootstrap {
            application_id,
            workspace_id,
            project_path,
            template_name,
        } => {
            commands::bootstrap::execute_bootstrap(
                application_id,
                workspace_id,
                project_path,
                template_name,
            )
            .await?
        }
    }

    Ok(())
}
