//
//  LocalComponentBuilderConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol LocalComponentBuilderConfig: AnyObject, Observable {
    // All builder configs must be generically initable since we use them in
    // environment objects that are required to be non-nil. So these builder
    // configs exist for all containers but just have nil fields by default.
    init()
}
