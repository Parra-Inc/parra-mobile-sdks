//
//  EpisodesTab.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct EpisodesTab: View {
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ParraFeedWidget(
                feedId: "{{ template.tabs.episodes.feed_id }}",
                config: ParraFeedConfiguration(
                    navigationTitle: "{{ template.tabs.episodes.title }}"{% if template.tabs.episodes.empty_state %},
                    emptyStateContent: ParraEmptyStateContent(
                        title: ParraLabelContent(text: "{{ template.tabs.episodes.empty_state.title }}"),
                        subtitle: ParraLabelContent(text: "{{ template.tabs.episodes.empty_state.subtitle }}"),
                        icon: .symbol("{{ template.tabs.episodes.empty_state.sf_symbol }}"),
                        primaryAction: {% if template.tabs.episodes.empty_state.cta %}ParraTextButtonContent(
                            text: ParraLabelContent(text: "{{ template.tabs.episodes.empty_state.cta.title }}")
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
        EpisodesTab(navigationPath: .constant(NavigationPath()))
    }
}
