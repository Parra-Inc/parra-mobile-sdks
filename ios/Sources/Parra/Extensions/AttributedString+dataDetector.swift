//
//  AttributedString+dataDetector.swift
//  Parra
//
//  Created by Mick MacCallum on 10/11/24.
//

import Foundation
import SwiftUI

extension String {
    func attributedStringWithHighlightedLinks(
        tint: Color,
        font: Font,
        foregroundColor: Color
    ) -> AttributedString {
        var attributedString = AttributedString(
            self
        )

        attributedString.font = font
        attributedString.foregroundColor = foregroundColor

        let types = NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult
            .CheckingType.phoneNumber.rawValue

        guard let detector = try? NSDataDetector(types: types) else {
            return attributedString
        }

        let matches = detector.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count)
        )

        for match in matches {
            let range = match.range
            let startIndex = attributedString.index(
                attributedString.startIndex,
                offsetByCharacters: range.lowerBound
            )

            let endIndex = attributedString.index(
                startIndex,
                offsetByCharacters: range.length
            )

            if match.resultType == .link, let url = match.url {
                attributedString[startIndex ..< endIndex].link = url
                attributedString[startIndex ..< endIndex].foregroundColor = tint

                if url.scheme == "mailto" {
                    attributedString[
                        startIndex ..< endIndex
                    ].backgroundColor = tint
                }
            }

            if match.resultType == .phoneNumber, let phoneNumber = match.phoneNumber {
                let url = URL(string: "tel:\(phoneNumber)")

                attributedString[startIndex ..< endIndex].link = url
                attributedString[startIndex ..< endIndex].foregroundColor = tint
            }
        }

        return attributedString
    }
}
