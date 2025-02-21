//
//  String+commaList.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/25.
//

import Foundation

extension [String] {
    func toCommaList() -> String {
        switch count {
        case 0:
            return ""
        case 1:
            return self[0]
        case 2:
            return "\(self[0]) & \(self[1])"
        default:
            let allButLast = dropLast().joined(separator: ", ")
            return "\(allButLast) & \(last!)"
        }
    }
}
