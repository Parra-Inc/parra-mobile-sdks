//
//  ParraColorSwatch.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraColorSwatch: Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        shade50: ParraColorConvertible,
        shade100: ParraColorConvertible,
        shade200: ParraColorConvertible,
        shade300: ParraColorConvertible,
        shade400: ParraColorConvertible,
        shade500: ParraColorConvertible,
        shade600: ParraColorConvertible,
        shade700: ParraColorConvertible,
        shade800: ParraColorConvertible,
        shade900: ParraColorConvertible,
        shade950: ParraColorConvertible,
        name: String? = nil
    ) {
        self.name = name
        self.shade50 = shade50.toParraColor()
        self.shade100 = shade100.toParraColor()
        self.shade200 = shade200.toParraColor()
        self.shade300 = shade300.toParraColor()
        self.shade400 = shade400.toParraColor()
        self.shade500 = shade500.toParraColor()
        self.shade600 = shade600.toParraColor()
        self.shade700 = shade700.toParraColor()
        self.shade800 = shade800.toParraColor()
        self.shade900 = shade900.toParraColor()
        self.shade950 = shade950.toParraColor()
    }

    public init(
        primary: ParraColor,
        name: String? = nil
    ) {
        self.name = name
        self.shade50 = primary.withLuminosity(0.98)
        self.shade100 = primary.withLuminosity(0.97)
        self.shade200 = primary.withLuminosity(0.952)
        self.shade300 = primary.withLuminosity(0.925)
        self.shade400 = primary.withLuminosity(0.825)
        self
            .shade500 =
            primary // when only a primary is provided, all others are derived from it.
        self.shade600 = primary.withLuminosity(0.47)
        self.shade700 = primary.withLuminosity(0.394)
        self.shade800 = primary.withLuminosity(0.326)
        self.shade900 = primary.withLuminosity(0.27)
        self.shade950 = primary.withLuminosity(0.17)
    }

    init(
        lightSwatch: ParraColorSwatch,
        darkSwatch: ParraColorSwatch,
        name: String? = nil
    ) {
        self.name = name

        self.shade50 = ParraColor(
            lightVariant: lightSwatch.shade50,
            darkVariant: darkSwatch.shade50
        )

        self.shade100 = ParraColor(
            lightVariant: lightSwatch.shade100,
            darkVariant: darkSwatch.shade100
        )

        self.shade200 = ParraColor(
            lightVariant: lightSwatch.shade200,
            darkVariant: darkSwatch.shade200
        )

        self.shade300 = ParraColor(
            lightVariant: lightSwatch.shade300,
            darkVariant: darkSwatch.shade300
        )

        self.shade400 = ParraColor(
            lightVariant: lightSwatch.shade400,
            darkVariant: darkSwatch.shade400
        )

        self.shade500 = ParraColor(
            lightVariant: lightSwatch.shade500,
            darkVariant: darkSwatch.shade500
        )

        self.shade600 = ParraColor(
            lightVariant: lightSwatch.shade600,
            darkVariant: darkSwatch.shade600
        )

        self.shade700 = ParraColor(
            lightVariant: lightSwatch.shade700,
            darkVariant: darkSwatch.shade700
        )

        self.shade800 = ParraColor(
            lightVariant: lightSwatch.shade800,
            darkVariant: darkSwatch.shade800
        )

        self.shade900 = ParraColor(
            lightVariant: lightSwatch.shade900,
            darkVariant: darkSwatch.shade900
        )

        self.shade950 = ParraColor(
            lightVariant: lightSwatch.shade950,
            darkVariant: darkSwatch.shade950
        )
    }

    // MARK: - Public

    public static let slate = ParraColorSwatch(
        shade50: 0xF8FAFC,
        shade100: 0xF1F5F9,
        shade200: 0xE2E8F0,
        shade300: 0xCBD5E1,
        shade400: 0x94A3B8,
        shade500: 0x64748B,
        shade600: 0x475569,
        shade700: 0x334155,
        shade800: 0x1E293B,
        shade900: 0x0F172A,
        shade950: 0x020617,
        name: "Slate"
    )

    public static let gray = ParraColorSwatch(
        shade50: 0xF9FAFB,
        shade100: 0xF3F4F6,
        shade200: 0xE5E7EB,
        shade300: 0xD1D5DB,
        shade400: 0x9CA3AF,
        shade500: 0x6B7280,
        shade600: 0x4B5563,
        shade700: 0x374151,
        shade800: 0x1F2937,
        shade900: 0x111827,
        shade950: 0x030712,
        name: "Gray"
    )

    public static let zinc = ParraColorSwatch(
        shade50: 0xFAFAFA,
        shade100: 0xF4F4F5,
        shade200: 0xE4E4E7,
        shade300: 0xD4D4D8,
        shade400: 0xA1A1AA,
        shade500: 0x71717A,
        shade600: 0x52525B,
        shade700: 0x3F3F46,
        shade800: 0x27272A,
        shade900: 0x18181B,
        shade950: 0x09090B,
        name: "Zinc"
    )

    public static let neutral = ParraColorSwatch(
        shade50: 0xFAFAFA,
        shade100: 0xF5F5F5,
        shade200: 0xE5E5E5,
        shade300: 0xD4D4D4,
        shade400: 0xA3A3A3,
        shade500: 0x737373,
        shade600: 0x525252,
        shade700: 0x404040,
        shade800: 0x262626,
        shade900: 0x171717,
        shade950: 0x0A0A0A,
        name: "Neutral"
    )

    public static let stone = ParraColorSwatch(
        shade50: 0xFAFAF9,
        shade100: 0xF5F5F4,
        shade200: 0xE7E5E4,
        shade300: 0xD6D3D1,
        shade400: 0xA8A29E,
        shade500: 0x78716C,
        shade600: 0x57534E,
        shade700: 0x44403C,
        shade800: 0x292524,
        shade900: 0x1C1917,
        shade950: 0x0C0A09,
        name: "Stone"
    )

    public static let red = ParraColorSwatch(
        shade50: 0xFEF2F2,
        shade100: 0xFEE2E2,
        shade200: 0xFECACA,
        shade300: 0xFCA5A5,
        shade400: 0xF87171,
        shade500: 0xEF4444,
        shade600: 0xDC2626,
        shade700: 0xB91C1C,
        shade800: 0x991B1B,
        shade900: 0x7F1D1D,
        shade950: 0x450A0A,
        name: "Red"
    )

    public static let orange = ParraColorSwatch(
        shade50: 0xFFF7ED,
        shade100: 0xFFEDD5,
        shade200: 0xFED7AA,
        shade300: 0xFDBA74,
        shade400: 0xFB923C,
        shade500: 0xF97316,
        shade600: 0xEA580C,
        shade700: 0xC2410C,
        shade800: 0x9A3412,
        shade900: 0x7C2D12,
        shade950: 0x431407,
        name: "Orange"
    )

    public static let amber = ParraColorSwatch(
        shade50: 0xFFFBEB,
        shade100: 0xFEF3C7,
        shade200: 0xFDE68A,
        shade300: 0xFCD34D,
        shade400: 0xFBBF24,
        shade500: 0xF59E0B,
        shade600: 0xD97706,
        shade700: 0xB45309,
        shade800: 0x92400E,
        shade900: 0x78350F,
        shade950: 0x451A03,
        name: "Amber"
    )

    public static let yellow = ParraColorSwatch(
        shade50: 0xFEFCE8,
        shade100: 0xFEF9C3,
        shade200: 0xFEF08A,
        shade300: 0xFDE047,
        shade400: 0xFACC15,
        shade500: 0xEAB308,
        shade600: 0xCA8A04,
        shade700: 0xA16207,
        shade800: 0x854D0E,
        shade900: 0x713F12,
        shade950: 0x422006,
        name: "Yellow"
    )

    public static let lime = ParraColorSwatch(
        shade50: 0xF7FEE7,
        shade100: 0xECFCCB,
        shade200: 0xD9F99D,
        shade300: 0xBEF264,
        shade400: 0xA3E635,
        shade500: 0x84CC16,
        shade600: 0x65A30D,
        shade700: 0x4D7C0F,
        shade800: 0x3F6212,
        shade900: 0x365314,
        shade950: 0x1A2E05,
        name: "Lime"
    )

    public static let green = ParraColorSwatch(
        shade50: 0xF0FDF4,
        shade100: 0xDCFCE7,
        shade200: 0xBBF7D0,
        shade300: 0x86EFAC,
        shade400: 0x4ADE80,
        shade500: 0x22C55E,
        shade600: 0x16A34A,
        shade700: 0x15803D,
        shade800: 0x166534,
        shade900: 0x14532D,
        shade950: 0x052E16,
        name: "Green"
    )

    public static let emerald = ParraColorSwatch(
        shade50: 0xECFDF5,
        shade100: 0xD1FAE5,
        shade200: 0xA7F3D0,
        shade300: 0x6EE7B7,
        shade400: 0x34D399,
        shade500: 0x10B981,
        shade600: 0x059669,
        shade700: 0x047857,
        shade800: 0x065F46,
        shade900: 0x064E3B,
        shade950: 0x022C22,
        name: "Emerald"
    )

    public static let teal = ParraColorSwatch(
        shade50: 0xF0FDFA,
        shade100: 0xCCFBF1,
        shade200: 0x99F6E4,
        shade300: 0x5EEAD4,
        shade400: 0x2DD4BF,
        shade500: 0x14B8A6,
        shade600: 0x0D9488,
        shade700: 0x0F766E,
        shade800: 0x115E59,
        shade900: 0x134E4A,
        shade950: 0x042F2E,
        name: "Teal"
    )

    public static let cyan = ParraColorSwatch(
        shade50: 0xECFEFF,
        shade100: 0xCFFAFE,
        shade200: 0xA5F3FC,
        shade300: 0x67E8F9,
        shade400: 0x22D3EE,
        shade500: 0x06B6D4,
        shade600: 0x0891B2,
        shade700: 0x0E7490,
        shade800: 0x155E75,
        shade900: 0x164E63,
        shade950: 0x083344,
        name: "Cyan"
    )

    public static let sky = ParraColorSwatch(
        shade50: 0xF0F9FF,
        shade100: 0xE0F2FE,
        shade200: 0xBAE6FD,
        shade300: 0x7DD3FC,
        shade400: 0x38BDF8,
        shade500: 0x0EA5E9,
        shade600: 0x0284C7,
        shade700: 0x0369A1,
        shade800: 0x075985,
        shade900: 0x0C4A6E,
        shade950: 0x082F49,
        name: "Sky"
    )

    public static let blue = ParraColorSwatch(
        shade50: 0xEFF6FF,
        shade100: 0xDBEAFE,
        shade200: 0xBFDBFE,
        shade300: 0x93C5FD,
        shade400: 0x60A5FA,
        shade500: 0x3B82F6,
        shade600: 0x2563EB,
        shade700: 0x1D4ED8,
        shade800: 0x1E40AF,
        shade900: 0x1E3A8A,
        shade950: 0x172554,
        name: "Blue"
    )

    public static let indigo = ParraColorSwatch(
        shade50: 0xEEF2FF,
        shade100: 0xE0E7FF,
        shade200: 0xC7D2FE,
        shade300: 0xA5B4FC,
        shade400: 0x818CF8,
        shade500: 0x6366F1,
        shade600: 0x4F46E5,
        shade700: 0x4338CA,
        shade800: 0x3730A3,
        shade900: 0x312E81,
        shade950: 0x1E1B4B,
        name: "Indigo"
    )

    public static let violet = ParraColorSwatch(
        shade50: 0xF5F3FF,
        shade100: 0xEDE9FE,
        shade200: 0xDDD6FE,
        shade300: 0xC4B5FD,
        shade400: 0xA78BFA,
        shade500: 0x8B5CF6,
        shade600: 0x7C3AED,
        shade700: 0x6D28D9,
        shade800: 0x5B21B6,
        shade900: 0x4C1D95,
        shade950: 0x2E1065,
        name: "Violet"
    )

    public static let purple = ParraColorSwatch(
        shade50: 0xFAF5FF,
        shade100: 0xF3E8FF,
        shade200: 0xE9D5FF,
        shade300: 0xD8B4FE,
        shade400: 0xC084FC,
        shade500: 0xA855F7,
        shade600: 0x9333EA,
        shade700: 0x7E22CE,
        shade800: 0x6B21A8,
        shade900: 0x581C87,
        shade950: 0x3B0764,
        name: "Purple"
    )

    public static let fuchsia = ParraColorSwatch(
        shade50: 0xFDF4FF,
        shade100: 0xFAE8FF,
        shade200: 0xF5D0FE,
        shade300: 0xF0ABFC,
        shade400: 0xE879F9,
        shade500: 0xD946EF,
        shade600: 0xC026D3,
        shade700: 0xA21CAF,
        shade800: 0x86198F,
        shade900: 0x701A75,
        shade950: 0x4A044E,
        name: "Fuchsia"
    )

    public static let pink = ParraColorSwatch(
        shade50: 0xFDF2F8,
        shade100: 0xFCE7F3,
        shade200: 0xFBCFE8,
        shade300: 0xF9A8D4,
        shade400: 0xF472B6,
        shade500: 0xEC4899,
        shade600: 0xDB2777,
        shade700: 0xBE185D,
        shade800: 0x9D174D,
        shade900: 0x831843,
        shade950: 0x500724,
        name: "Pink"
    )

    public static let rose = ParraColorSwatch(
        shade50: 0xFFF1F2,
        shade100: 0xFFE4E6,
        shade200: 0xFECDD3,
        shade300: 0xFDA4AF,
        shade400: 0xFB7185,
        shade500: 0xF43F5E,
        shade600: 0xE11D48,
        shade700: 0xBE123C,
        shade800: 0x9F1239,
        shade900: 0x881337,
        shade950: 0x4C0519,
        name: "Rose"
    )

    public let name: String?
    public let shade50: ParraColor
    public let shade100: ParraColor
    public let shade200: ParraColor
    public let shade300: ParraColor
    public let shade400: ParraColor
    public let shade500: ParraColor
    public let shade600: ParraColor
    public let shade700: ParraColor
    public let shade800: ParraColor
    public let shade900: ParraColor
    public let shade950: ParraColor

    public var id: String {
        return String(hashValue)
    }

    // MARK: - Internal

    static let standardSwatches: [ParraColorSwatch] = [
        slate, gray, zinc, neutral, stone, red, orange, amber,
        yellow, lime, green, emerald, teal, cyan, sky, blue,
        indigo, violet, purple, fuchsia, pink, rose
    ]

    var allShades: [(String, ParraColor)] {
        return [
            ("50", shade50),
            ("100", shade100),
            ("200", shade200),
            ("300", shade300),
            ("400", shade400),
            ("500", shade500),
            ("600", shade600),
            ("700", shade700),
            ("800", shade800),
            ("900", shade900),
            ("950", shade950)
        ]
    }

    func darkened(to luminosity: CGFloat) -> ParraColorSwatch {
        return ParraColorSwatch(
            shade50: shade50.withLuminosity(luminosity),
            shade100: shade100.withLuminosity(luminosity),
            shade200: shade200.withLuminosity(luminosity),
            shade300: shade300.withLuminosity(luminosity),
            shade400: shade400.withLuminosity(luminosity),
            shade500: shade500.withLuminosity(luminosity),
            shade600: shade600.withLuminosity(luminosity),
            shade700: shade700.withLuminosity(luminosity),
            shade800: shade800.withLuminosity(luminosity),
            shade900: shade900.withLuminosity(luminosity),
            shade950: shade950.withLuminosity(luminosity)
        )
    }

    func with(name: String?) -> ParraColorSwatch {
        return ParraColorSwatch(
            shade50: shade50,
            shade100: shade100,
            shade200: shade200,
            shade300: shade300,
            shade400: shade400,
            shade500: shade500,
            shade600: shade600,
            shade700: shade700,
            shade800: shade800,
            shade900: shade900,
            shade950: shade950,
            name: name
        )
    }
}
