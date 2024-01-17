//
//  URLRequest+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension URLRequest: ParraSanitizedDictionaryConvertible {
    var sanitized: ParraSanitizedDictionary {
        var params: [String : Any] = [
            "timeout_interval": timeoutInterval,
            "should_handle_cookies": httpShouldHandleCookies,
            "should_use_pipelining": httpShouldUsePipelining,
            "allows_cellular_access": allowsCellularAccess,
            "allows_constrainted_network_access": allowsConstrainedNetworkAccess,
            "allows_expensive_network_access": allowsExpensiveNetworkAccess,
            "network_service_type": networkServiceType.rawValue,
            "attribution": attribution.description,
            "assumes_http3_capable": assumesHTTP3Capable,
            "cache_policy": cachePolicy.description
        ]

        if #available(iOS 16.1, *) {
            params["requires_dns_sec_validation"] = requiresDNSSECValidation
        }

        if let httpMethod {
            params["method"] = httpMethod
        }

        if let url {
            params["url"] = url.absoluteString
        }

        if let httpBody {
            params["body"] = String(data: httpBody, encoding: .utf8) ?? httpBody.base64EncodedString()
        }

        if let allHTTPHeaderFields {
            params["headers"] = ParraDataSanitizer.sanitize(
                httpHeaders: allHTTPHeaderFields
            )
        }

        return ParraSanitizedDictionary(dictionary: params)
    }
}
