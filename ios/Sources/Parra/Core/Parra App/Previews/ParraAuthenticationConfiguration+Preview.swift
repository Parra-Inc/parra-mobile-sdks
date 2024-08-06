//
//  ParraAuthenticationConfiguration+Preview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraAuthType {
    nonisolated static let preview: ParraAuthType = .custom {
        return .uuid
    }
}
