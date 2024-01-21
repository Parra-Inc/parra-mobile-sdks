//
//  FeedbackFormWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackFormWidget: Container {
    typealias Factory = FeedbackFormWidgetComponentFactory
    typealias Config = FeedbackFormConfig
    typealias ContentObserver = FeedbackFormContentObserver
    typealias Style = WidgetStyle

    var componentFactory: ComponentFactory<Factory>

    var config: Config

    @StateObject
    var contentObserver: FeedbackFormContentObserver

    @StateObject
    var themeObserver: ParraThemeObserver

    var body: some View {
        let titleStyle = defaultTextStyle(with: .init(
            font: .largeTitle
        ))

        let descriptionStyle = defaultTextStyle(with: .init(
            font: .subheadline
        ))

        let submitButtonStyle = ButtonStyle(
            background: .red,
            cornerRadius: .zero,
            padding: .zero
        )
        
        let content = contentObserver.content

        withEnvironmentObjects {
            VStack {
                componentFactory.build(
                    component: \.title,
                    config: config.title,
                    content: content.title,
                    localStyle: titleStyle,
                    defaultComponentType: TextComponent.self
                )

                componentFactory.build(
                    component: \.description,
                    config: config.description,
                    content: content.description,
                    localStyle: descriptionStyle,
                    defaultComponentType: TextComponent.self
                )

                componentFactory.build(
                    component: \.submitButton,
                    config: config.submitButton,
                    content: content.submitButton,
                    localStyle: submitButtonStyle,
                    defaultComponentType: ContainedButtonComponent.self
                )
            }
        }
    }
}

#Preview {
    let global = GlobalComponentStylizer(containedButtonStylizer:  { config, state, defaultStyle in
        return .init(
            background: .red,
            cornerRadius: defaultStyle.cornerRadius,
            padding: defaultStyle.padding
        )
    })

    let local = FeedbackFormWidgetComponentFactory(
        titleBuilder: nil,
        descriptionBuilder: { config, content, defaultStyle in
            if let content {
                Text(content.text)
                    .font(.subheadline)
            } else {
                nil
            }
        },
        submitButtonBuilder: nil
    )

    return FeedbackFormWidget(
        componentFactory: .init(
            local: local,
            global: global,
            theme: ParraTheme.default
        ),
        config: .init(
            title: .init(),
            description: .init(),
            selectFields: .init(),
            textFields: .init(),
            submitButton: .init(
                style: .primary,
                size: .large,
                isMaxWidth: true,
                title: .init()
            )
        ),
        contentObserver: .init(formData: .init(title: "Title", description: "description", fields: [])),
        themeObserver: .init(
            theme: .default,
            notificationCenter: ParraNotificationCenter()
        )
    )
}
