//
//  NSAttributedString.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/10/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    static let poweredByParraUIKit: NSAttributedString = {
        return NSAttributedString(poweredByParra)
    }()

    static let poweredByParra: AttributedString = {
        var defaultAttributes = AttributeContainer()
        defaultAttributes[AttributeScopes.UIKitAttributes.KernAttribute.self] = 0.24
        defaultAttributes[AttributeScopes.UIKitAttributes.FontAttribute.self] = UIFont.systemFont(ofSize: 8.0, weight: .bold)

        var poweredBy = AttributedString("Powered by ", attributes: defaultAttributes)

        var parraLogoAttributes = AttributeContainer()
        parraLogoAttributes[AttributeScopes.UIKitAttributes.FontAttribute.self] =
            UIFont(name: "Pacifico-Regular", size: 11) ?? UIFont.boldSystemFont(ofSize: 11)

        let parraLogo = AttributedString("Parra", attributes: parraLogoAttributes)

        poweredBy.append(parraLogo)

        return poweredBy
    }()
}
