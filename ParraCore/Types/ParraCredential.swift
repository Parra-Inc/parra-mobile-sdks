//
//  ParraCredential.swift
//  Parra Core
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation
import UIKit

public struct ParraCredential: Codable, Equatable {
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}
