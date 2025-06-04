//
//  ParraConfiguration.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//
{%- assign primary = template.theme.default.palette.primary -%}
{%- assign secondary = template.theme.default.palette.secondary -%}
{%- assign primary_background = template.theme.default.components.background.primary -%}
{%- assign secondary_background = template.theme.default.components.background.secondary -%}
{%- assign primary_text = template.theme.default.components.typography.variants.heading.color -%}
{%- assign secondary_text = template.theme.default.components.typography.variants.body.color -%}
{%- assign primary_separator = template.theme.default.components.separator.primary.background_color -%}
{%- assign secondary_separator = template.theme.default.components.separator.secondary.background_color -%}
{%- assign primary_chip_text = template.theme.default.components.chip.variants.primary.color -%}
{%- assign secondary_chip_text = template.theme.default.components.chip.variants.secondary.color -%}
{%- assign primary_chip_background = template.theme.default.components.chip.variants.primary.background_color -%}
{%- assign secondary_chip_background = template.theme.default.components.chip.variants.secondary.background_color -%}
{%- assign error = template.theme.default.palette.danger -%}
{%- assign warning = template.theme.default.palette.warning -%}
{%- assign info = template.theme.default.palette.info -%}
{%- assign success = template.theme.default.palette.success -%}

{% if template.theme.dark %}
{%- assign primary_dark = template.theme.dark.palette.primary -%}
{%- assign secondary_dark = template.theme.dark.palette.secondary -%}
{%- assign primary_background_dark = template.theme.dark.components.background.primary -%}
{%- assign secondary_background_dark = template.theme.dark.components.background.secondary -%}
{%- assign primary_text_dark = template.theme.dark.components.typography.variants.heading.color -%}
{%- assign secondary_text_dark = template.theme.dark.components.typography.variants.body.color -%}
{%- assign primary_separator_dark = template.theme.dark.components.separator.primary.background_color -%}
{%- assign secondary_separator_dark = template.theme.dark.components.separator.secondary.background_color -%}
{%- assign primary_chip_text_dark = template.theme.dark.components.chip.variants.primary.color -%}
{%- assign secondary_chip_text_dark = template.theme.dark.components.chip.variants.secondary.color -%}
{%- assign primary_chip_background_dark = template.theme.dark.components.chip.variants.primary.background_color -%}
{%- assign secondary_chip_background_dark = template.theme.dark.components.chip.variants.secondary.background_color -%}
{%- assign error_dark = template.theme.dark.palette.danger -%}
{%- assign warning_dark = template.theme.dark.palette.warning -%}
{%- assign info_dark = template.theme.dark.palette.info -%}
{%- assign success_dark = template.theme.dark.palette.success -%}
{% endif %}

import Parra
import SwiftUI
{% if template.theme.default %}
private let defaultTheme = ParraTheme(
    lightPalette: ParraColorPalette(
        primary: ParraColorSwatch(
            shade50: Color.fromHex("{{ primary.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ primary.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ primary.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ primary.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ primary.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ primary.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ primary.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ primary.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ primary.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ primary.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ primary.shade_950.hex_value }}")
        ),
        secondary: ParraColorSwatch(
            shade50: Color.fromHex("{{ secondary.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ secondary.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ secondary.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ secondary.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ secondary.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ secondary.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ secondary.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ secondary.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ secondary.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ secondary.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ secondary.shade_950.hex_value }}")
        ),
        primaryBackground: Color.fromHex("{{ primary_background.hex_value }}"),
        secondaryBackground: Color.fromHex("{{ secondary_background.hex_value }}"),
        primaryText: Color.fromHex("{{ primary_text.hex_value }}"),
        secondaryText: Color.fromHex("{{ secondary_text.hex_value }}"),
        primarySeparator: Color.fromHex("{{ primary_separator.hex_value }}"),
        secondarySeparator: Color.fromHex("{{ secondary_separator.hex_value }}"),
        primaryChipText: Color.fromHex("{{ primary_chip_text.hex_value }}"),
        secondaryChipText: Color.fromHex("{{ secondary_chip_text.hex_value }}"),
        primaryChipBackground: Color.fromHex("{{ primary_chip_background.hex_value }}"),
        secondaryChipBackground: Color.fromHex("{{ secondary_chip_background.hex_value }}"),
        error: ParraColorSwatch(
            shade50: Color.fromHex("{{ error.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ error.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ error.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ error.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ error.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ error.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ error.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ error.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ error.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ error.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ error.shade_950.hex_value }}")
        ),
        warning: ParraColorSwatch(
            shade50: Color.fromHex("{{ warning.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ warning.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ warning.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ warning.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ warning.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ warning.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ warning.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ warning.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ warning.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ warning.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ warning.shade_950.hex_value }}")
        ),
        info: ParraColorSwatch(
            shade50: Color.fromHex("{{ info.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ info.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ info.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ info.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ info.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ info.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ info.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ info.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ info.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ info.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ info.shade_950.hex_value }}")
        ),
        success: ParraColorSwatch(
            shade50: Color.fromHex("{{ success.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ success.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ success.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ success.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ success.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ success.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ success.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ success.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ success.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ success.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ success.shade_950.hex_value }}")
        )
    ),
    {% if template.theme.dark %}
    darkPalette: ParraColorPalette(
        primary: ParraColorSwatch(
            shade50: Color.fromHex("{{ primary_dark.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ primary_dark.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ primary_dark.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ primary_dark.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ primary_dark.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ primary_dark.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ primary_dark.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ primary_dark.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ primary_dark.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ primary_dark.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ primary_dark.shade_950.hex_value }}")
        ),
        secondary: ParraColorSwatch(
            shade50: Color.fromHex("{{ secondary_dark.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ secondary_dark.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ secondary_dark.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ secondary_dark.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ secondary_dark.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ secondary_dark.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ secondary_dark.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ secondary_dark.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ secondary_dark.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ secondary_dark.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ secondary_dark.shade_950.hex_value }}")
        ),
        primaryBackground: Color.fromHex("{{ primary_background_dark.hex_value }}"),
        secondaryBackground: Color.fromHex("{{ secondary_background_dark.hex_value }}"),
        primaryText: Color.fromHex("{{ primary_text_dark.hex_value }}"),
        secondaryText: Color.fromHex("{{ secondary_text_dark.hex_value }}"),
        primarySeparator: Color.fromHex("{{ primary_separator_dark.hex_value }}"),
        secondarySeparator: Color.fromHex("{{ secondary_separator_dark.hex_value }}"),
        primaryChipText: Color.fromHex("{{ primary_chip_text_dark.hex_value }}"),
        secondaryChipText: Color.fromHex("{{ secondary_chip_text_dark.hex_value }}"),
        primaryChipBackground: Color.fromHex("{{ primary_chip_background_dark.hex_value }}"),
        secondaryChipBackground: Color.fromHex("{{ secondary_chip_background_dark.hex_value }}"),
        error: ParraColorSwatch(
            shade50: Color.fromHex("{{ error_dark.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ error_dark.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ error_dark.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ error_dark.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ error_dark.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ error_dark.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ error_dark.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ error_dark.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ error_dark.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ error_dark.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ error_dark.shade_950.hex_value }}")
        ),
        warning: ParraColorSwatch(
            shade50: Color.fromHex("{{ warning_dark.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ warning_dark.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ warning_dark.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ warning_dark.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ warning_dark.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ warning_dark.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ warning_dark.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ warning_dark.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ warning_dark.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ warning_dark.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ warning_dark.shade_950.hex_value }}")
        ),
        info: ParraColorSwatch(
            shade50: Color.fromHex("{{ info_dark.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ info_dark.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ info_dark.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ info_dark.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ info_dark.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ info_dark.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ info_dark.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ info_dark.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ info_dark.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ info_dark.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ info_dark.shade_950.hex_value }}")
        ),
        success: ParraColorSwatch(
            shade50: Color.fromHex("{{ success_dark.shade_50.hex_value }}"),
            shade100: Color.fromHex("{{ success_dark.shade_100.hex_value }}"),
            shade200: Color.fromHex("{{ success_dark.shade_200.hex_value }}"),
            shade300: Color.fromHex("{{ success_dark.shade_300.hex_value }}"),
            shade400: Color.fromHex("{{ success_dark.shade_400.hex_value }}"),
            shade500: Color.fromHex("{{ success_dark.shade_500.hex_value }}"),
            shade600: Color.fromHex("{{ success_dark.shade_600.hex_value }}"),
            shade700: Color.fromHex("{{ success_dark.shade_700.hex_value }}"),
            shade800: Color.fromHex("{{ success_dark.shade_800.hex_value }}"),
            shade900: Color.fromHex("{{ success_dark.shade_900.hex_value }}"),
            shade950: Color.fromHex("{{ success_dark.shade_950.hex_value }}")
        )
    )
    {% else %}
    darkPalette: nil
    {% endif %}
)
{% else %}
private let defaultTheme = ParraTheme.default
{% endif %}

extension ParraConfiguration {
    static let shared = ParraConfiguration(
        pushNotificationOptions: .allWithoutProvisional,
        theme: defaultTheme
    )
}
