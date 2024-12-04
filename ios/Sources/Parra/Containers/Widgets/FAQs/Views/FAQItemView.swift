//
//  FAQItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

struct FAQItemView: View {
    // MARK: - Internal

    let faq: ParraAppFaq

    var body: some View {
        DisclosureGroup {
            componentFactory.buildLabel(
                text: faq.body
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 18)
        } label: {
            componentFactory.buildLabel(
                text: faq.title,
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .headline)
                )
            )
        }
        .disclosureGroupStyle(FaqDisclosureStyle())
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}

private struct FaqDisclosureStyle: DisclosureGroupStyle {
    // MARK: - Internal

    func makeBody(
        configuration: Configuration
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.bouncy(duration: 0.25)) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label

                    Spacer()

                    componentFactory.buildImage(
                        content: .symbol("chevron.right"),
                        localAttributes: ParraAttributes.Image(
                            size: CGSize(width: 16, height: 16)
                        )
                    )
                    .rotationEffect(
                        Angle(
                            degrees: configuration.isExpanded ? 90 : 0
                        )
                    )
                    .animation(nil, value: configuration.isExpanded)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 18)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if configuration.isExpanded {
                configuration.content
            }
        }
        .background(
            theme.palette.secondaryBackground
        )
        .applyCornerRadii(size: .md, from: theme)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
}
