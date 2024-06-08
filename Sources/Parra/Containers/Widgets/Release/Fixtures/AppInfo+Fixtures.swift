//
//  AppInfo+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraAppInfo: ParraFixture {
    static func validStates() -> [ParraAppInfo] {
        return [
            ParraAppInfo(
                versionToken: "1.0.0",
                newInstalledVersionInfo: NewInstalledVersionInfo(
                    configuration: AppReleaseConfiguration(
                        title: "My new release",
                        hasOtherReleases: false
                    ),
                    release: AppRelease.validStates()[0]
                ),
                tenant: TenantAppInfoStub(
                    id: .uuid,
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    name: "My org",
                    issuer: URL(string: "https://parra-demo.com")!,
                    subdomain: "mick",
                    isTest: false,
                    parentTenantId: nil,
                    logo: nil,
                    domains: [
                        Domain(
                            id: .uuid,
                            type: .external,
                            name: "parra-demo.com",
                            title: "External Domain",
                            host: "parra-demo.com",
                            url: URL(string: "https://parra-demo.com")!,
                            data: .externalDomainData(
                                ExternalDomainData(
                                    status: .error,
                                    domain: "parra-demo.com",
                                    disabled: false
                                )
                            )
                        ),
                        Domain(
                            id: .uuid,
                            type: .subdomain,
                            name: "parra-public-demo",
                            title: "Subdomain",
                            host: "parra-public-demo.parra.io",
                            url: URL(
                                string: "https://parra-public-demo.parra.io"
                            )!,
                            data: nil
                        ),
                        Domain(
                            id: .uuid,
                            type: .fallback,
                            name: "tenant-201cbcf0-b5d6-4079-9e4d-177ae04cc9f4",
                            title: "Fallback",
                            host: "tenant-201cbcf0-b5d6-4079-9e4d-177ae04cc9f4.parra.io",
                            url: URL(
                                string: "https://tenant-201cbcf0-b5d6-4079-9e4d-177ae04cc9f4.parra.io"
                            )!,
                            data: nil
                        )
                    ],
                    urls: [
                        URL(
                            string: "https://parra-public-demo.parra.io"
                        )!,
                        URL(
                            string: "https://tenant-201cbcf0-b5d6-4079-9e4d-177ae04cc9f4.parra.io"
                        )!
                    ],
                    entitlements: []
                ),
                auth: ParraAppAuthInfo.validStates()[0],
                legal: LegalInfo.validStates()[0]
            )
        ]
    }

    static func invalidStates() -> [ParraAppInfo] {
        return []
    }
}
