//
//  Font.TextStyle+CustomStringConvertible.swift
//
//
//  Created by Mick MacCallum on 9/6/24.
//

import SwiftUI

extension Font.TextStyle: CustomStringConvertible {
    public var description: String {
        switch self {
        case .largeTitle:
            return "largeTitle"
        case .title:
            return "title"
        case .headline:
            return "headline"
        case .subheadline:
            return "subheadline"
        case .body:
            return "body"
        case .callout:
            return "callout"
        case .caption:
            return "caption"
        case .footnote:
            return "footnote"
        default:
            return "unknown"
        }
    }
}
