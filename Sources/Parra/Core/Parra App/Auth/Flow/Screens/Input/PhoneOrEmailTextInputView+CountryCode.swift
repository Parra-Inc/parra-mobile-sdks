//
//  PhoneOrEmailTextInputView+CountryCode.swift
//  Parra
//
//  Created by Mick MacCallum on 5/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension PhoneOrEmailTextInputView {
    struct CountryCode: Codable, Identifiable {
        static let allCountries: [CountryCode] = Bundle.parraBundle
            .decode("CountryCodes.json")
        static let usa = allCountries.first(where: { $0.code == "US" })!

        let id: String
        let name: String
        let flag: String
        let code: String
        let dial_code: String
        let pattern: String
        let limit: Int
    }
}
