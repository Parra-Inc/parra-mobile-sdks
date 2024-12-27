//
//  PhotoWell+WellState.swift
//  Parra
//
//  Created by Mick MacCallum on 4/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraPhotoWell {
    enum WellState: Equatable {
        case empty
        case asset(ParraImageAsset)
        case url(URL)
        case loadingFromLibrary
        case loaded(UIImage)
        case processing(UIImage)
        case error(Error)

        // MARK: - Internal

        var isLoading: Bool {
            switch self {
            case .loadingFromLibrary, .processing:
                return true
            default:
                return false
            }
        }

        static func == (
            lhs: ParraPhotoWell.WellState,
            rhs: ParraPhotoWell.WellState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case (.loadingFromLibrary, .loadingFromLibrary):
                return true
            case (.asset(let lhsAsset), .asset(let rhsAsset)):
                return lhsAsset == rhsAsset
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
