//
//  ReleaseContentObserver+ReleaseContentType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ReleaseContentObserver {
    enum ReleaseContentType: Equatable {
        case newInstalledVersion(NewInstalledVersionInfo)
        case stub(AppReleaseStub)
    }
}
