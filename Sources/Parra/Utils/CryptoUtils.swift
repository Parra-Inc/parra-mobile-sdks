//
//  CryptoUtils.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import CommonCrypto
import CryptoKit
import Foundation
import Security

enum CryptoUtils {
    static func encyptData(
        _ data: Data
    ) throws -> (Data, String) {
        let key = SymmetricKey(size: .bits256)
        let savedKey = key.withUnsafeBytes {
            return Data(Array($0)).base64EncodedString()
        }

        let result = try AES.GCM.seal(
            data,
            using: key
        )

        guard let combined = result.combined else {
            throw ParraError.message(
                "Could not access combined encryption data"
            )
        }

        return (combined, savedKey)
    }

    static func decryptData(
        _ data: Data,
        using keyString: String
    ) throws -> Data {
        guard let keyData = Data(base64Encoded: keyString) else {
            throw ParraError.message(
                "Can not decrypt data with invalid keyString"
            )
        }

        let key = SymmetricKey(data: keyData)

        let sealedBoxRestored = try AES.GCM.SealedBox(
            combined: data
        )

        return try AES.GCM.open(sealedBoxRestored, using: key)
    }
}
