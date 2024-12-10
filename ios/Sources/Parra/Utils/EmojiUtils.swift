//
//  EmojiUtils.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import CoreText
import Foundation
import SwiftUI

enum EmojiUtils {
    struct Emoji: Hashable {
        // MARK: - Lifecycle

        init(value: String, name: String) {
            self.value = value
            self.name = name
        }

        // MARK: - Internal

        let value: String
        let name: String
    }

    private(set) static var allEmojis: [Emoji] = {
        let ranges = [
            0x1F600 ... 0x1F64F, // Emoticons
            0x1F900 ... 0x1F9FF, // Supplemental Symbols and Pictographs
            9_100 ... 9_300, // Misc items
            0x2600 ... 0x26FF, // Misc symbols
            0x2705 ... 0x27BF, // Dingbats
            0x1F300 ... 0x1F5FF, // Misc Symbols and Pictographs
            0x1F680 ... 0x1F6FF, // Transport and Map
            0x1F1E6 ... 0x1F1FF // Regional country flags
        ]

        var allEmoji: [Emoji] = ranges.joined().compactMap {
            guard let scalar = UnicodeScalar($0) else {
                return nil
            }

            let emoji = String(Character(scalar))
            let emojiName = name(for: emoji)

            let uniChars = Array(emoji.utf16)
            let font = CTFontCreateWithName("AppleColorEmoji" as CFString, 0.0, .none)
            var glyphs: [CGGlyph] = [0, 0]

            guard CTFontGetGlyphsForCharacters(
                font,
                uniChars,
                &glyphs,
                uniChars.count
            ) else {
                return nil
            }

            return Emoji(
                value: emoji,
                name: emojiName
            )
        }

        return allEmoji
    }()

    static func name(
        for emoji: String
    ) -> String {
        let string = NSMutableString(string: String(emoji))
        var range = CFRangeMake(0, CFStringGetLength(string))
        CFStringTransform(string, &range, kCFStringTransformToUnicodeName, false)

        guard let firstName = string.components(separatedBy: "\\N").first else {
            return "Unknown"
        }

        return firstName.trimmingPrefix("\\N")
            .trimmingCharacters(in: .punctuationCharacters)
            .capitalized
    }

    func getName(for emoji: String) -> String? {
        let string = NSMutableString(string: String(emoji))
        var range = CFRangeMake(0, CFStringGetLength(string))

        CFStringTransform(string, &range, kCFStringTransformToUnicodeName, false)

        guard let firstName = string.components(separatedBy: "\\\\N").first else {
            return nil
        }

        return firstName.trimmingPrefix("\\N")
            .trimmingCharacters(in: .punctuationCharacters)
            .capitalized
    }
}
