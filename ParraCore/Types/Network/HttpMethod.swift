//
//  HttpMethod.swift
//  Parra Core
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    
    var allowsBody: Bool {
        return [.put, .post, .patch].contains(self)
    }
}
