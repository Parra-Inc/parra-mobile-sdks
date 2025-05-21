//
//  UniversalOverlay.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/25.
//

import SwiftUI

/// Extensions
extension View {
    @ViewBuilder
    func universalOverlay(
        animation: Animation = .snappy,
        show: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            UniversalOverlayModifier(
                animation: animation,
                show: show,
                viewContent: content
            )
        )
    }
}

/// Shared Universal Overlay Properties
@Observable
class UniversalOverlayProperties {
    struct OverlayView: Identifiable {
        var id: String = UUID().uuidString
        var view: AnyView
    }

    var window: UIWindow?
    var views: [OverlayView] = []
}

private struct UniversalOverlayModifier<ViewContent: View>: ViewModifier {
    // MARK: - Internal

    var animation: Animation
    @Binding var show: Bool
    @ViewBuilder var viewContent: ViewContent

    func body(content: Content) -> some View {
        content
            .onChange(of: show, initial: true) { _, newValue in
                if newValue {
                    addView()
                } else {
                    removeView()
                }
            }
    }

    // MARK: - Private

    /// Local View Properties
    @Environment(UniversalOverlayProperties.self) private var properties
    @State private var viewID: String?

    private func addView() {
        if properties.window != nil && viewID == nil {
            viewID = UUID().uuidString
            guard let viewID else {
                return
            }

            withAnimation(animation) {
                properties.views.append(.init(id: viewID, view: .init(viewContent)))
            }
        }
    }

    private func removeView() {
        if let viewID {
            withAnimation(animation) {
                properties.views.removeAll(where: { $0.id == viewID })
            }

            self.viewID = nil
        }
    }
}

struct UniversalOverlayViews: View {
    // MARK: - Internal

    var body: some View {
        ZStack {
            ForEach(properties.views) {
                $0.view
            }
        }
    }

    // MARK: - Private

    @Environment(UniversalOverlayProperties.self) private var properties
}

class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event),
              let rootView = rootViewController?.view else
        {
            return nil
        }

        if #available(iOS 18, *) {
            for subview in rootView.subviews.reversed() {
                /// Finding if any of rootview's is receving hit test
                let pointInSubView = subview.convert(point, from: rootView)
                if subview.hitTest(pointInSubView, with: event) != nil {
                    return hitView
                }
            }

            return nil
        } else {
            return hitView == rootView ? nil : hitView
        }
    }
}
