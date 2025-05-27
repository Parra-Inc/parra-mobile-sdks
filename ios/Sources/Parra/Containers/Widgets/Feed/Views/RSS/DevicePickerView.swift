//
//  DevicePickerView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/27/25.
//

import AVKit
import SwiftUI

struct DevicePickerView: UIViewRepresentable {
    // MARK: - Lifecycle

    init(
        activeTintColor: Color,
        tintColor: Color
    ) {
        self.activeTintColor = activeTintColor
        self.tintColor = tintColor
    }

    // MARK: - Internal

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeUIView(context: Context) -> UIView {
        let routePickerView = AVRoutePickerView()

        routePickerView.activeTintColor = UIColor(activeTintColor)
        routePickerView.tintColor = UIColor(tintColor)
        routePickerView.backgroundColor = .clear
        routePickerView.prioritizesVideoDevices = false

        return routePickerView
    }

    // MARK: - Private

    private let activeTintColor: Color
    private let tintColor: Color
}
