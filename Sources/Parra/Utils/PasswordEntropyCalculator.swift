//
//  PasswordEntropyCalculator.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum PasswordEntropyCalculator {
    enum Strength: CustomStringConvertible {
        case veryWeak
        case weak
        case moderate
        case strong
        case veryStrong

        // MARK: - Internal

        var description: String {
            switch self {
            case .veryWeak:
                return "Very Weak"
            case .weak:
                return "Weak"
            case .moderate:
                return "Moderate"
            case .strong:
                return "Strong"
            case .veryStrong:
                return "Very Strong"
            }
        }

        func color(
            for theme: ParraTheme
        ) -> ParraColor {
            switch self {
            case .veryWeak:
                return theme.palette.error.toParraColor()
            case .weak:
                return theme.palette.warning.toParraColor()
            case .moderate:
                return theme.palette.secondary.toParraColor()
            case .strong:
                return theme.palette.success.toParraColor()
            case .veryStrong:
                return theme.palette.success.toParraColor()
            }
        }
    }

    static func calculateEntropy(
        for password: String
    ) -> Double {
        let trimmed = password.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty else {
            return 0
        }

        var hasLowercase = false,
            hasUppercase = false,
            hasDecimal = false,
            hasPunctuation = false,
            hasSymbol = false,
            hasWhitespace = false,
            hasNonBase = false

        var charsetSize: Double = 0

        trimmed.enumerateSubstrings(
            in: trimmed.startIndex ..< trimmed.endIndex,
            options: .byComposedCharacterSequences
        ) { subString, _, _, _ in
            guard let unicodeScalars = subString?.first?.unicodeScalars.first else {
                return
            }

            if !hasLowercase,
               CharacterSet.lowercaseLetters.contains(unicodeScalars)
            {
                hasLowercase = true
                charsetSize += 26
            }

            if !hasUppercase,
               CharacterSet.uppercaseLetters.contains(unicodeScalars)
            {
                hasUppercase = true
                charsetSize += 26
            }

            if !hasDecimal,
               CharacterSet.decimalDigits.contains(unicodeScalars)
            {
                hasDecimal = true
                charsetSize += 10
            }

            if !hasSymbol, CharacterSet.symbols.contains(unicodeScalars) {
                hasSymbol = true
                charsetSize += 10
            }

            if !hasPunctuation,
               CharacterSet.punctuationCharacters.contains(unicodeScalars)
            {
                hasPunctuation = true
                charsetSize += 20
            }

            if !hasWhitespace,
               CharacterSet.whitespacesAndNewlines.contains(unicodeScalars)
            {
                hasWhitespace = true
                charsetSize += 1
            }

            if !hasNonBase,
               CharacterSet.nonBaseCharacters.contains(unicodeScalars)
            {
                hasNonBase = true
                charsetSize += 32 + 128
            }
        }

        return log2(charsetSize) * Double(trimmed.count)
    }

    static func calculateStrength(
        for password: String
    ) -> Strength {
        let entropy = calculateEntropy(for: password)

        return strength(of: entropy)
    }

    static func strength(
        of entropy: Double
    ) -> Strength {
        if entropy < 28 {
            return .veryWeak
        } else if entropy < 36 {
            return .weak
        } else if entropy < 60 {
            return .moderate
        } else if entropy < 128 {
            return .strong
        } else {
            return .veryStrong
        }
    }
}
