//
//  NSURLRequest.CachePolicy+CustomStringConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension NSURLRequest.CachePolicy: CustomStringConvertible {
    public var description: String {
        switch self {
        case .useProtocolCachePolicy:
            return "use_protocol_cache_policy"
        case .reloadIgnoringLocalCacheData:
            return "reload_ignoring_local_cache_data"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "reload_ignoring_local_and_remote_cache_data"
        case .reloadIgnoringCacheData:
            return "reload_ignoring_cache_data"
        case .returnCacheDataElseLoad:
            return "return_cache_data_else_load"
        case .returnCacheDataDontLoad:
            return "return_cache_data_dont_load"
        case .reloadRevalidatingCacheData:
            return "reload_revalidating_cache_data"
        @unknown default:
            return "unknown"
        }
    }
}
