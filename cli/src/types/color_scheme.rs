use std::env;

use colored::Color as ColoredColor;
use inquire::ui::Color as InquireColor;

#[derive(Debug, Clone, Copy)]
struct RGB {
    r: u8,
    g: u8,
    b: u8,
}

// rgb(219, 39, 119);
const PARRA_PINK: RGB = RGB {
    r: 219,
    g: 39,
    b: 119,
};

// rgb(162, 51, 234);
const PARRA_PURPLE: RGB = RGB {
    r: 162,
    g: 51,
    b: 234,
};

#[allow(dead_code)]
#[derive(Debug, Clone, Copy)]
pub struct ParraColorSchemeForColored {
    pub prefix_color: ColoredColor,
    pub highlight_color: ColoredColor,
    pub selection_color: ColoredColor,
    pub answer_color: ColoredColor,
    pub help_color: ColoredColor,
    pub error_color: ColoredColor,
}

#[derive(Debug, Clone, Copy)]
pub struct ParraColorSchemeForInquire {
    pub prefix_color: InquireColor,
    pub highlight_color: InquireColor,
    pub selection_color: InquireColor,
    pub answer_color: InquireColor,
    pub help_color: InquireColor,
    pub error_color: InquireColor,
}

pub fn get_supported_parra_inquire_color_scheme() -> ParraColorSchemeForInquire
{
    return match env::var("COLORTERM") {
        Ok(_) => get_parra_default_inquire_color_scheme(),
        Err(_) => get_parra_muted_inquire_color_scheme(),
    };
}

pub fn get_supported_parra_colored_color_scheme() -> ParraColorSchemeForColored
{
    return match env::var("COLORTERM") {
        Ok(_) => get_parra_default_colored_color_scheme(),
        Err(_) => get_parra_muted_colored_color_scheme(),
    };
}

fn get_parra_default_colored_color_scheme() -> ParraColorSchemeForColored {
    return ParraColorSchemeForColored {
        prefix_color: ColoredColor::TrueColor {
            r: PARRA_PURPLE.r,
            g: PARRA_PURPLE.g,
            b: PARRA_PURPLE.b,
        },
        highlight_color: ColoredColor::TrueColor {
            r: PARRA_PINK.r,
            g: PARRA_PINK.g,
            b: PARRA_PINK.b,
        },
        selection_color: ColoredColor::TrueColor {
            r: PARRA_PINK.r,
            g: PARRA_PINK.g,
            b: PARRA_PINK.b,
        },
        answer_color: ColoredColor::TrueColor {
            r: PARRA_PURPLE.r,
            g: PARRA_PURPLE.g,
            b: PARRA_PURPLE.b,
        },
        help_color: ColoredColor::Yellow,
        error_color: ColoredColor::BrightRed,
    };
}

fn get_parra_muted_colored_color_scheme() -> ParraColorSchemeForColored {
    return ParraColorSchemeForColored {
        prefix_color: ColoredColor::Magenta,
        highlight_color: ColoredColor::BrightMagenta,
        selection_color: ColoredColor::BrightMagenta,
        answer_color: ColoredColor::Magenta,
        help_color: ColoredColor::Yellow,
        error_color: ColoredColor::BrightRed,
    };
}

pub fn get_parra_default_inquire_color_scheme() -> ParraColorSchemeForInquire {
    return ParraColorSchemeForInquire {
        prefix_color: InquireColor::rgb(
            PARRA_PURPLE.r,
            PARRA_PURPLE.g,
            PARRA_PURPLE.b,
        ),
        highlight_color: InquireColor::rgb(
            PARRA_PINK.r,
            PARRA_PINK.g,
            PARRA_PINK.b,
        ),
        selection_color: InquireColor::rgb(
            PARRA_PINK.r,
            PARRA_PINK.g,
            PARRA_PINK.b,
        ),
        answer_color: InquireColor::rgb(
            PARRA_PURPLE.r,
            PARRA_PURPLE.g,
            PARRA_PURPLE.b,
        ),
        help_color: InquireColor::DarkYellow,
        error_color: InquireColor::LightRed,
    };
}

pub fn get_parra_muted_inquire_color_scheme() -> ParraColorSchemeForInquire {
    return ParraColorSchemeForInquire {
        prefix_color: InquireColor::DarkMagenta,
        highlight_color: InquireColor::LightMagenta,
        selection_color: InquireColor::LightMagenta,
        answer_color: InquireColor::DarkMagenta,
        help_color: InquireColor::DarkYellow,
        error_color: InquireColor::LightRed,
    };
}
