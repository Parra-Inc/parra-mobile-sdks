//
//  SheetDismissType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum SheetDismissType: Equatable {
    case cancelled
    case completed
    case failed(String)
}
