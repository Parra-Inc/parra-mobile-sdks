//
//  CreatorUpdateTemplatePickerCell.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/25.
//

import SwiftUI

struct CustomLabel: LabelStyle {
    var spacing: Double = 0.0

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

struct CreatorUpdateTemplatePickerCell: View {
    // MARK: - Internal

    var template: CreatorUpdateTemplate
    @StateObject var contentObserver: CreatorUpdateWidget.ContentObserver

    var body: some View {
        Button {
            Logger.debug("Selected creator update template", [
                "id": template.id,
                "name": template.name
            ])

            contentObserver.creatorUpdate = .init(template: template)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    componentFactory.buildLabel(
                        text: template.name,
                        localAttributes: .default(with: .headline)
                    )

                    Spacer()
                }

                HStack {
                    let postSymbol = switch template.visibility.postVisibility {
                    case .public:
                        "eye.fill"
                    case .private:
                        "eye.slash.fill"
                    }

                    CreatorUpdateTagBadge(
                        title: "Post",
                        icon: postSymbol,
                        style: .secondary
                    )

                    let attachmentSymbol: String? = switch template.visibility
                        .attachmentVisibility
                    {
                    case .public:
                        "eye.fill"
                    case .private:
                        "eye.slash.fill"
                    case .none:
                        nil
                    }

                    if let attachmentSymbol {
                        CreatorUpdateTagBadge(
                            title: "Attachments",
                            icon: attachmentSymbol,
                            style: .secondary
                        )
                    }

                    withContent(content: template.topic.value) { content in
                        CreatorUpdateTagBadge(
                            title: content.displayName,
                            icon: "number",
                            style: .secondary
                        )
                    }

                    Spacer()
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .buttonStyle(ContentCardButtonStyle())
        .simultaneousGesture(TapGesture())
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
}
