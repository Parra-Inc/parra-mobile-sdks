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
                    id: ParraInternal.Demo.workspaceId,
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    name: "My org",
                    issuer: "parra-demo.com",
                    subdomain: "parra-public-demo",
                    isTest: false,
                    parentTenantId: nil,
                    logo: .init(
                        id: .uuid,
                        size: .init(width: 512, height: 512),
                        url: URL(
                            string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/\(ParraInternal.Demo.workspaceId)/logo/52efae8d-53ec-42e1-9c04-f4aa733762b0.png"
                        )!
                    ),
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
                                    name: "parra-demo.com",
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
                            name: "tenant-\(ParraInternal.Demo.workspaceId)",
                            title: "Fallback",
                            host: "tenant-\(ParraInternal.Demo.workspaceId).parra.io",
                            url: URL(
                                string: "https://tenant-\(ParraInternal.Demo.workspaceId).parra.io"
                            )!,
                            data: nil
                        )
                    ],
                    urls: [
                        URL(
                            string: "https://parra-demo.com"
                        )!,
                        URL(
                            string: "https://parra-public-demo.parra.io"
                        )!,
                        URL(
                            string: "https://tenant-\(ParraInternal.Demo.workspaceId).parra.io"
                        )!
                    ],
                    entitlements: [],
                    hideBranding: false
                ),
                auth: ParraAppAuthInfo.validStates()[0],
                legal: LegalInfo.validStates()[0],
                application: ParraApplicationIosConfig(
                    name: "Parra iOS Demo App",
                    description: "The Parra iOS Demo app using the native Swift SDK.",
                    appId: "6479621013",
                    teamId: "6D44Q764PG",
                    bundleId: "com.parra.parra-ios-client"
                )
            )
        ]
    }

    static func invalidStates() -> [ParraAppInfo] {
        return []
    }
}
