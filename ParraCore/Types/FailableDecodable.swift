//
//  FailableDecodable.swift
//  ParraCore
//
//  Created by Mick MacCallum on 10/15/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

struct FailableDecodable<Base: Decodable>: Decodable {
    let result: Result<Base, DecodingError>

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            self.result = .success(try container.decode(Base.self))
        } catch let decodeError as DecodingError {
            self.result = .failure(decodeError)
        } catch let error {
            throw error
        }
    }
}
