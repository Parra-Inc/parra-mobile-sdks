//
//  ParraAppContent.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public protocol ParraAppContent: View {
    associatedtype AuthenticatedContent: View
    associatedtype UnauthenticatedContent: View

    func authenticatedContent(for user: ParraUser) -> AuthenticatedContent
    func unauthenticatedContent(for error: Error?) -> UnauthenticatedContent
}
