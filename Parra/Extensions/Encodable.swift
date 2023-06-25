//
//  Encodable.swift
//  Parra
//
//  Created by Mick MacCallum on 2/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder.parraEncoder.encode(self)

        guard let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any] else {
            throw ParraError.jsonError("Unable to convert object to JSON. Object: \(String(describing: self))")
        }

        return dictionary
    }
}

