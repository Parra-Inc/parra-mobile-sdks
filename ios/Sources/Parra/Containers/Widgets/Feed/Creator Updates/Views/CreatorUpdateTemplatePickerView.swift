//
//  CreatorUpdateTemplatePickerView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/25.
//

import SwiftUI

struct CreatorUpdateTemplatePickerView: View {
    // MARK: - Internal

    var templates: [CreatorUpdateTemplate]
    @StateObject var contentObserver: CreatorUpdateWidget.ContentObserver

    var body: some View {
        Form {
            Section {
                ForEach(templates) { template in
                    CreatorUpdateTemplatePickerCell(
                        template: template,
                        contentObserver: contentObserver
                    )
                }
            } header: {
                Text("Templates")
            } footer: {
                Text(
                    "Create and edit templates in the [Parra dashboard](https://parra.io/dashboard/creator/updates/configuration)"
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
                .multilineTextAlignment(.center)
                .tint(theme.palette.primary)
            }
            .listRowBackground(theme.palette.secondaryBackground)
        }
        .background(theme.palette.primaryBackground)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}
