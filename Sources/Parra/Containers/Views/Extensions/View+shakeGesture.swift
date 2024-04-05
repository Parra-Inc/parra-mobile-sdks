//
//  View+shakeGesture.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(
        rawValue: "deviceDidShakeNotification"
    )
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
    override open func motionEnded(
        _ motion: UIEvent.EventSubtype,
        with event: UIEvent?
    ) {
        if motion == .motionShake {
            NotificationCenter.default.post(
                name: UIDevice.deviceDidShakeNotification,
                object: nil
            )
        }
    }
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIDevice.deviceDidShakeNotification
                )
            ) { _ in
                action()
            }
    }
}

extension View {
    func onShake(
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(
            DeviceShakeViewModifier(
                action: action
            )
        )
    }
}
