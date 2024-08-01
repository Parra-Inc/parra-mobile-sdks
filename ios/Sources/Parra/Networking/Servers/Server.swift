//
//  Server.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

protocol Server {
    var configuration: ServerConfiguration { get }
    var appState: ParraAppState { get }
    var appConfig: ParraConfiguration { get }

    var delegate: ServerDelegate? { get }

    var urlSessionDelegateProxy: UrlSessionDelegateProxy { get }
}
