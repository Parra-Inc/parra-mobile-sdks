//
//  ParraColorSwatch.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraColorSwatch: Hashable, Identifiable {
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

    public static let slate = ParraColorSwatch(
        shade50: 0xf8fafc,
        shade100: 0xf1f5f9,
        shade200: 0xe2e8f0,
        shade300: 0xcbd5e1,
        shade400: 0x94a3b8,
        shade500: 0x64748b,
        shade600: 0x475569,
        shade700: 0x334155,
        shade800: 0x1e293b,
        shade900: 0x0f172a,
        shade950: 0x020617,
        name: "Slate"
    )

    public static let gray = ParraColorSwatch(
        shade50: 0xf9fafb,
        shade100: 0xf3f4f6,
        shade200: 0xe5e7eb,
        shade300: 0xd1d5db,
        shade400: 0x9ca3af,
        shade500: 0x6b7280,
        shade600: 0x4b5563,
        shade700: 0x374151,
        shade800: 0x1f2937,
        shade900: 0x111827,
        shade950: 0x030712,
        name: "Gray"
    )

    public static let zinc = ParraColorSwatch(
        shade50: 0xfafafa,
        shade100: 0xf4f4f5,
        shade200: 0xe4e4e7,
        shade300: 0xd4d4d8,
        shade400: 0xa1a1aa,
        shade500: 0x71717a,
        shade600: 0x52525b,
        shade700: 0x3f3f46,
        shade800: 0x27272a,
        shade900: 0x18181b,
        shade950: 0x09090b,
        name: "Zinc"
    )

    public static let neutral = ParraColorSwatch(
        shade50: 0xfafafa,
        shade100: 0xf5f5f5,
        shade200: 0xe5e5e5,
        shade300: 0xd4d4d4,
        shade400: 0xa3a3a3,
        shade500: 0x737373,
        shade600: 0x525252,
        shade700: 0x404040,
        shade800: 0x262626,
        shade900: 0x171717,
        shade950: 0x0a0a0a,
        name: "Neutral"
    )

    public static let stone = ParraColorSwatch(
        shade50: 0xfafaf9,
        shade100: 0xf5f5f4,
        shade200: 0xe7e5e4,
        shade300: 0xd6d3d1,
        shade400: 0xa8a29e,
        shade500: 0x78716c,
        shade600: 0x57534e,
        shade700: 0x44403c,
        shade800: 0x292524,
        shade900: 0x1c1917,
        shade950: 0x0c0a09,
        name: "Stone"
    )

    public static let red = ParraColorSwatch(
        shade50: 0xfef2f2,
        shade100: 0xfee2e2,
        shade200: 0xfecaca,
        shade300: 0xfca5a5,
        shade400: 0xf87171,
        shade500: 0xef4444,
        shade600: 0xdc2626,
        shade700: 0xb91c1c,
        shade800: 0x991b1b,
        shade900: 0x7f1d1d,
        shade950: 0x450a0a,
        name: "Red"
    )

    public static let orange = ParraColorSwatch(
        shade50: 0xfff7ed,
        shade100: 0xffedd5,
        shade200: 0xfed7aa,
        shade300: 0xfdba74,
        shade400: 0xfb923c,
        shade500: 0xf97316,
        shade600: 0xea580c,
        shade700: 0xc2410c,
        shade800: 0x9a3412,
        shade900: 0x7c2d12,
        shade950: 0x431407,
        name: "Orange"
    )

    public static let amber = ParraColorSwatch(
        shade50: 0xfffbeb,
        shade100: 0xfef3c7,
        shade200: 0xfde68a,
        shade300: 0xfcd34d,
        shade400: 0xfbbf24,
        shade500: 0xf59e0b,
        shade600: 0xd97706,
        shade700: 0xb45309,
        shade800: 0x92400e,
        shade900: 0x78350f,
        shade950: 0x451a03,
        name: "Amber"
    )

    public static let yellow = ParraColorSwatch(
        shade50: 0xfefce8,
        shade100: 0xfef9c3,
        shade200: 0xfef08a,
        shade300: 0xfde047,
        shade400: 0xfacc15,
        shade500: 0xeab308,
        shade600: 0xca8a04,
        shade700: 0xa16207,
        shade800: 0x854d0e,
        shade900: 0x713f12,
        shade950: 0x422006,
        name: "Yellow"
    )

    public static let lime = ParraColorSwatch(
        shade50: 0xf7fee7,
        shade100: 0xecfccb,
        shade200: 0xd9f99d,
        shade300: 0xbef264,
        shade400: 0xa3e635,
        shade500: 0x84cc16,
        shade600: 0x65a30d,
        shade700: 0x4d7c0f,
        shade800: 0x3f6212,
        shade900: 0x365314,
        shade950: 0x1a2e05,
        name: "Lime"
    )

    public static let green = ParraColorSwatch(
        shade50: 0xf0fdf4,
        shade100: 0xdcfce7,
        shade200: 0xbbf7d0,
        shade300: 0x86efac,
        shade400: 0x4ade80,
        shade500: 0x22c55e,
        shade600: 0x16a34a,
        shade700: 0x15803d,
        shade800: 0x166534,
        shade900: 0x14532d,
        shade950: 0x052e16,
        name: "Green"
    )

    public static let emerald = ParraColorSwatch(
        shade50: 0xecfdf5,
        shade100: 0xd1fae5,
        shade200: 0xa7f3d0,
        shade300: 0x6ee7b7,
        shade400: 0x34d399,
        shade500: 0x10b981,
        shade600: 0x059669,
        shade700: 0x047857,
        shade800: 0x065f46,
        shade900: 0x064e3b,
        shade950: 0x022c22,
        name: "Emerald"
    )

    public static let teal = ParraColorSwatch(
        shade50: 0xf0fdfa,
        shade100: 0xccfbf1,
        shade200: 0x99f6e4,
        shade300: 0x5eead4,
        shade400: 0x2dd4bf,
        shade500: 0x14b8a6,
        shade600: 0x0d9488,
        shade700: 0x0f766e,
        shade800: 0x115e59,
        shade900: 0x134e4a,
        shade950: 0x042f2e,
        name: "Teal"
    )

    public static let cyan = ParraColorSwatch(
        shade50: 0xecfeff,
        shade100: 0xcffafe,
        shade200: 0xa5f3fc,
        shade300: 0x67e8f9,
        shade400: 0x22d3ee,
        shade500: 0x06b6d4,
        shade600: 0x0891b2,
        shade700: 0x0e7490,
        shade800: 0x155e75,
        shade900: 0x164e63,
        shade950: 0x083344,
        name: "Cyan"
    )

    public static let sky = ParraColorSwatch(
        shade50: 0xf0f9ff,
        shade100: 0xe0f2fe,
        shade200: 0xbae6fd,
        shade300: 0x7dd3fc,
        shade400: 0x38bdf8,
        shade500: 0x0ea5e9,
        shade600: 0x0284c7,
        shade700: 0x0369a1,
        shade800: 0x075985,
        shade900: 0x0c4a6e,
        shade950: 0x082f49,
        name: "Sky"
    )

    public static let blue = ParraColorSwatch(
        shade50: 0xeff6ff,
        shade100: 0xdbeafe,
        shade200: 0xbfdbfe,
        shade300: 0x93c5fd,
        shade400: 0x60a5fa,
        shade500: 0x3b82f6,
        shade600: 0x2563eb,
        shade700: 0x1d4ed8,
        shade800: 0x1e40af,
        shade900: 0x1e3a8a,
        shade950: 0x172554,
        name: "Blue"
    )

    public static let indigo = ParraColorSwatch(
        shade50: 0xeef2ff,
        shade100: 0xe0e7ff,
        shade200: 0xc7d2fe,
        shade300: 0xa5b4fc,
        shade400: 0x818cf8,
        shade500: 0x6366f1,
        shade600: 0x4f46e5,
        shade700: 0x4338ca,
        shade800: 0x3730a3,
        shade900: 0x312e81,
        shade950: 0x1e1b4b,
        name: "Indigo"
    )

    public static let violet = ParraColorSwatch(
        shade50: 0xf5f3ff,
        shade100: 0xede9fe,
        shade200: 0xddd6fe,
        shade300: 0xc4b5fd,
        shade400: 0xa78bfa,
        shade500: 0x8b5cf6,
        shade600: 0x7c3aed,
        shade700: 0x6d28d9,
        shade800: 0x5b21b6,
        shade900: 0x4c1d95,
        shade950: 0x2e1065,
        name: "Violet"
    )

    public static let purple = ParraColorSwatch(
        shade50: 0xfaf5ff,
        shade100: 0xf3e8ff,
        shade200: 0xe9d5ff,
        shade300: 0xd8b4fe,
        shade400: 0xc084fc,
        shade500: 0xa855f7,
        shade600: 0x9333ea,
        shade700: 0x7e22ce,
        shade800: 0x6b21a8,
        shade900: 0x581c87,
        shade950: 0x3b0764,
        name: "Purple"
    )

    public static let fuchsia = ParraColorSwatch(
        shade50: 0xfdf4ff,
        shade100: 0xfae8ff,
        shade200: 0xf5d0fe,
        shade300: 0xf0abfc,
        shade400: 0xe879f9,
        shade500: 0xd946ef,
        shade600: 0xc026d3,
        shade700: 0xa21caf,
        shade800: 0x86198f,
        shade900: 0x701a75,
        shade950: 0x4a044e,
        name: "Fuchsia"
    )

    public static let pink = ParraColorSwatch(
        shade50: 0xfdf2f8,
        shade100: 0xfce7f3,
        shade200: 0xfbcfe8,
        shade300: 0xf9a8d4,
        shade400: 0xf472b6,
        shade500: 0xec4899,
        shade600: 0xdb2777,
        shade700: 0xbe185d,
        shade800: 0x9d174d,
        shade900: 0x831843,
        shade950: 0x500724,
        name: "Pink"
    )

    public static let rose = ParraColorSwatch(
        shade50: 0xfff1f2,
        shade100: 0xffe4e6,
        shade200: 0xfecdd3,
        shade300: 0xfda4af,
        shade400: 0xfb7185,
        shade500: 0xf43f5e,
        shade600: 0xe11d48,
        shade700: 0xbe123c,
        shade800: 0x9f1239,
        shade900: 0x881337,
        shade950: 0x4c0519,
        name: "Rose"
    )

    internal static let standardSwatches: [ParraColorSwatch] = [
        slate, gray, zinc, neutral, stone, red, orange, amber, 
        yellow, lime, green, emerald, teal, cyan, sky, blue,
        indigo, violet, purple, fuchsia, pink, rose
    ]

    internal var allShades: [(String, ParraColor)] {
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
        self.shade500 = primary // when only a primary is provided, all others are derived from it.
        self.shade600 = primary.withLuminosity(0.47)
        self.shade700 = primary.withLuminosity(0.394)
        self.shade800 = primary.withLuminosity(0.326)
        self.shade900 = primary.withLuminosity(0.27)
        self.shade950 = primary.withLuminosity(0.17)
    }

    internal init(
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

    internal func darkened(to luminosity: CGFloat) -> ParraColorSwatch {
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

    internal func with(name: String?) -> ParraColorSwatch {
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
