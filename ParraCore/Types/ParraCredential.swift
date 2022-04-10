//
//  ParraCredential.swift
//  Parra Core
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation
import UIKit

@objc(PARParraCredential)
public class ParraCredential: NSObject, Codable {
    public var token: String
    
    @objc public init(token: String) {
        self.token = token
    }
    
    @objc public class func credential(withToken token: String) -> ParraCredential {
        return ParraCredential(token: token)
    }
}
