//
//  PhoneNumberFormatter.swift
//  Parra
//
//  Created by Mick MacCallum on 6/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

class PhoneNumberFormatter: Formatter {
    // MARK: - Lifecycle

    required init(
        pattern: String,
        replacementCharacter: Character = "#",
        enabled: Bool = true
    ) {
        self.pattern = pattern
        self.replacementCharacter = replacementCharacter
        self.enabled = enabled

        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    let pattern: String
    let replacementCharacter: Character
    let enabled: Bool

    override func string(for obj: Any?) -> String? {
        guard let value = obj as? String else {
            return nil
        }

        guard enabled else {
            return value
        }

        return applyPhoneNumberPattern(
            on: value
        )
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        obj?.pointee = string as NSString
        return true
    }

    func applyPhoneNumberPattern(
        on input: String
    ) -> String {
        var pureNumber = input.replacingOccurrences(
            of: "[^0-9\\+]",
            with: "",
            options: .regularExpression
        )

        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                return pureNumber
            }

            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else {
                continue
            }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }

        return pureNumber
    }
}
