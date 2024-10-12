//
//  Parra+ContainerRenderer.swift
//  Parra
//
//  Created by Mick MacCallum on 10/11/24.
//

import Foundation

public extension Parra {
    static var containerRenderer: ParraContainerRenderer {
        return `default`.parraInternal.containerRenderer
    }
}
