//
//  TextButtonComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol TextButtonComponentType: View {
    var config: TextButtonConfig { get }
    var content: TextButtonContent { get }
}
