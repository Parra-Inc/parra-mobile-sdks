//
//  ParraAppContent.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
public protocol ParraAppContent: View {
    associatedtype AuthenticatedContent: View
    associatedtype UnauthenticatedContent: View

    func authenticatedContent() -> AuthenticatedContent
    func unauthenticatedContent() -> UnauthenticatedContent
}
