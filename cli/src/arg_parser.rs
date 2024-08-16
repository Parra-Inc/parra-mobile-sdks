use std::fmt::{Debug, Display};

use clap::{Parser, Subcommand, ValueEnum};

#[derive(Parser)]
#[command(version, about, long_about = "")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Command,
}

#[derive(Debug, Clone, ValueEnum)]
// converted to/from kebab-case by default, which matches template directory names.
pub enum TemplateName {
    Default,
    RevenueCat,
}

impl Display for TemplateName {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let output = match self {
            TemplateName::Default => "default",
            TemplateName::RevenueCat => "revenue-cat",
        };

        write!(f, "{}", output)
    }
}

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct BootstrapCommandArgs {
    /// The identifier of the application you want to bootstrap. You can find
    /// this value here: https://parra.io/dashboard/applications
    /// If you don't provide this value, you will be prompted to select an
    /// application or create a new one.
    #[arg(short = 'a', long = "application-id")]
    pub application_id: Option<String>,

    /// The identifier of the workspace that owns your application in the Parra
    /// dashboard. You can find this value here: https://parra.io/dashboard/settings
    /// If you don't provide this value, you will be prompted to select a workspace or
    /// create a new one.
    #[arg(short = 'w', long = "workspace-id")]
    pub workspace_id: Option<String>,

    /// The path where you want to create your project. If you don't provide this
    /// value, you will be prompted to enter a path.
    #[arg(short = 'p', long = "project-path")]
    pub project_path: Option<String>,

    #[arg(value_enum, short = 't', long = "template", default_value_t = TemplateName::Default)]
    pub template_name: TemplateName,
}

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct LoginCommandArgs {}

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct LogoutCommandArgs {}

#[derive(Subcommand)]
pub enum Command {
    /// Creates a new Parra project. This command will guide you through selecting
    /// or creating a workspace and application, and then create a new project in
    /// the directory of your choice. Once complete, you can open the project in
    /// Xcode and start building your app.
    Bootstrap(BootstrapCommandArgs),
    /// Authenticates with the Parra API using a device auth flow. You will be asked
    /// to open a page in the browser and perform a login to the Parra dashboard.
    Login(LoginCommandArgs),
    /// Clears Parra authentication tokens from your local state. Subsequent commands
    /// that require authentication will prompt you to log in again.
    Logout(LogoutCommandArgs),
}

pub fn parse_args() -> Cli {
    Cli::parse()
}
