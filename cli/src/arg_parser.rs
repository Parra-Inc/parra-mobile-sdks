use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(version, about, long_about = "")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Creates a new Parra project. This command will guide you through selecting
    /// or creating a workspace and application, and then create a new project in
    /// the directory of your choice. Once complete, you can open the project in
    /// Xcode and start building your app.
    Bootstrap {
        /// The identifier of the application you want to bootstrap. You can find
        /// this value here: https://parra.io/dashboard/applications
        /// If you don't provide this value, you will be prompted to select an
        /// application or create a new one.
        #[arg(short = 'a', long = "application-id")]
        application_id: Option<String>,

        /// The identifier of the workspace that owns your application in the Parra
        /// dashboard. You can find this value here: https://parra.io/dashboard/settings
        /// If you don't provide this value, you will be prompted to select a workspace or
        /// create a new one.
        #[arg(short = 'w', long = "workspace-id")]
        workspace_id: Option<String>,

        /// The path where you want to create your project. If you don't provide this
        /// value, you will be prompted to enter a path.
        #[arg(short = 'p', long = "project-path")]
        project_path: Option<String>,
    },
}

pub fn parse_args() -> Cli {
    Cli::parse()
}
