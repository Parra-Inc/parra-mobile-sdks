//
//  SignInWithAppleUserName.swift
//  Parra
//
//  Created by Mick MacCallum on 12/2/24.
//

import Foundation

struct SignInWithAppleUserName {
    // MARK: - Lifecycle

    init(
        _ components: PersonNameComponents?
    ) {
        if let components {
            self.longFormattedName = components.formatted(
                .name(style: .long)
            )

            self.mediumFormattedName = components.formatted(
                .name(style: .medium)
            )

            self.shortFormattedName = components.formatted(
                .name(style: .short)
            )

            self.abbreviatedFormattedName = components.formatted(
                .name(style: .abbreviated)
            )
        } else {
            self.longFormattedName = nil
            self.mediumFormattedName = nil
            self.shortFormattedName = nil
            self.abbreviatedFormattedName = nil
        }

        self.namePrefix = components?.namePrefix
        self.givenName = components?.givenName
        self.middleName = components?.middleName
        self.familyName = components?.familyName
        self.nameSuffix = components?.nameSuffix
        self.nickname = components?.nickname
    }

    // MARK: - Internal

    let longFormattedName: String?
    let mediumFormattedName: String?
    let shortFormattedName: String?
    let abbreviatedFormattedName: String?

    let namePrefix: String?
    let givenName: String?
    let middleName: String?
    let familyName: String?
    let nameSuffix: String?
    let nickname: String?

    var dictionary: [String: String] {
        var dictionary: [String: String] = [:]

        if let namePrefix {
            dictionary["name_prefix"] = namePrefix
        }

        if let givenName {
            dictionary["given_name"] = givenName
        }

        if let middleName {
            dictionary["middle_name"] = middleName
        }

        if let familyName {
            dictionary["family_name"] = familyName
        }

        if let nameSuffix {
            dictionary["name_suffix"] = nameSuffix
        }

        if let nickname {
            dictionary["nickname"] = nickname
        }

        if let longFormattedName {
            dictionary["long_formatted_name"] = longFormattedName
        }

        if let mediumFormattedName {
            dictionary["medium_formatted_name"] = mediumFormattedName
        }

        if let shortFormattedName {
            dictionary["short_formatted_name"] = shortFormattedName
        }

        if let abbreviatedFormattedName {
            dictionary["abbreviated_formatted_name"] = abbreviatedFormattedName
        }

        return dictionary
    }
}
