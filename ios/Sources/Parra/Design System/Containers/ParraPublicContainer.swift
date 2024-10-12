//
//  ParraPublicContainer.swift
//  Parra
//
//  Created by Mick MacCallum on 2/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ParraPublicContainer: View {
    associatedtype Wrapped: ParraContainer
}
