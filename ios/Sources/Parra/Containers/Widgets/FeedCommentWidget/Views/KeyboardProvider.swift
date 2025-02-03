//
//  KeyboardProvider.swift
//  Parra
//
//  Created by Mick MacCallum on 2/3/25.
//

import SwiftUI

struct KeyboardProvider: ViewModifier {
    var keyboardHeight: Binding<CGFloat>

    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillShowNotification),
                perform: { notification in
                    guard let userInfo = notification.userInfo,
                          let keyboardRect =
                          userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return
                    }

                    keyboardHeight.wrappedValue = keyboardRect.height
                }
            ).onReceive(
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillHideNotification),
                perform: { _ in
                    keyboardHeight.wrappedValue = 0
                }
            )
    }
}

public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        modifier(KeyboardProvider(keyboardHeight: state))
    }
}
