//
//  VideosTab.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct VideosTab: View {
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ParraFeedWidget(
                feedId: "{{ template.tabs.videos.feed_id }}",
                config: ParraFeedConfiguration(
                    navigationTitle: "{{ template.tabs.videos.title }}"{% if template.tabs.videos.empty_state %},
                    emptyStateContent: ParraEmptyStateContent(
                        title: ParraLabelContent(text: "{{ template.tabs.videos.empty_state.title }}"),
                        subtitle: ParraLabelContent(text: "{{ template.tabs.videos.empty_state.subtitle }}"),
                        icon: .symbol("{{ template.tabs.videos.empty_state.sf_symbol }}"),
                        primaryAction: {% if template.tabs.videos.empty_state.cta %}ParraTextButtonContent(
                            text: ParraLabelContent(text: "{{ template.tabs.videos.empty_state.cta.title }}")
                        ){% else %}nil{% endif %}
                    ){% endif %}
                ),
                navigationPath: $navigationPath
            )
        }
    }
}

#Preview {
    ParraAppPreview {
        VideosTab(navigationPath: .constant(NavigationPath()))
    }
}
