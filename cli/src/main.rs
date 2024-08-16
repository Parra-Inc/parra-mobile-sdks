use std::env;
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
use inquire::ui::{Attributes, Color, RenderConfig, StyleSheet, Styled};
use types::color_scheme::get_supported_parra_inquire_color_scheme;

use crate::arg_parser::Command;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let cli = arg_parser::parse_args();

    apply_cli_theme();

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

fn apply_cli_theme() {
    let render_config = match env::var("NO_COLOR") {
        Ok(_) => RenderConfig::empty(),
        Err(_) => {
            let scheme = get_supported_parra_inquire_color_scheme();

            create_render_config(
                &scheme.prefix_color,
                &scheme.highlight_color,
                &scheme.selection_color,
                &scheme.answer_color,
                &scheme.help_color,
                &scheme.error_color,
            )
        }
    };

    inquire::set_global_render_config(render_config)
}

fn create_render_config(
    prefix_color: &Color,
    highlight_color: &Color,
    selection_color: &Color,
    answer_color: &Color,
    help_color: &Color,
    error_color: &Color,
) -> RenderConfig<'static> {
    let mut render_config = RenderConfig::default();

    render_config.highlighted_option_prefix =
        Styled::new("→").with_fg(*highlight_color);

    render_config.scroll_up_prefix = Styled::new("⇞");
    render_config.scroll_down_prefix = Styled::new("⇟");

    render_config.selected_option = Some(
        StyleSheet::new()
            .with_attr(Attributes::BOLD)
            .with_fg(*selection_color),
    );

    render_config.error_message = render_config
        .error_message
        .with_prefix(Styled::new("❌").with_fg(*error_color));

    render_config.prompt_prefix = Styled::new(">").with_fg(*prefix_color);
    render_config.answered_prompt_prefix = Styled::new("✅");

    render_config.answer = StyleSheet::new()
        .with_attr(Attributes::ITALIC)
        .with_fg(*answer_color);

    render_config.help_message = StyleSheet::new().with_fg(*help_color);

    return render_config;
}
