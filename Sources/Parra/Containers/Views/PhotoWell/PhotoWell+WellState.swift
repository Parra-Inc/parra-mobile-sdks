//
//  PhotoWell+WellState.swift
//  Parra
//
//  Created by Mick MacCallum on 4/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension PhotoWell {
    enum WellState: Equatable {
        case empty
        case url(URL)
        case loadingFromLibrary
        case loaded(UIImage)
        case error(Error)

        // MARK: - Internal

        var isLoading: Bool {
            switch self {
            case .loadingFromLibrary:
                return true
            default:
                return false
            }
        }

        static func == (
            lhs: PhotoWell.WellState,
            rhs: PhotoWell.WellState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case (.loadingFromLibrary, .loadingFromLibrary):
                return true
            case (.url(let lhsUrl), .url(let rhsUrl)):
                return lhsUrl == rhsUrl
            case (.loaded, .loaded):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError
                    .localizedDescription
            default:
                return false
            }
        }
    }
}