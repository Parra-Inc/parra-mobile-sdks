//
//  AlertManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct InlineAlert: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text(
            "Hello, world!"
        )/*@END_MENU_TOKEN@*/
    }
}

#Preview {
    InlineAlert()
}

class AlertManager: ObservableObject {
    // MARK: - Internal

    struct Alert {
        let config: AlertConfig
        let content: AlertContent
        let attributes: AlertAttributes
    }

    func showToast(
        config: AlertConfig,
        content: AlertContent,
        attributes: AlertAttributes
    ) {}

    // MARK: - Private

    @State private var currentAlert: Alert? = nil
}
