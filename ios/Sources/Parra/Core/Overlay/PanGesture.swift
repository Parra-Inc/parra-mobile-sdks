//
//  PanGesture.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/25.
//

import SwiftUI

struct PanGesture: UIGestureRecognizerRepresentable {
    struct Value {
        var translation: CGSize
        var velocity: CGSize
    }

    var onChange: (Value) -> Void
    var onEnd: (Value) -> Void

    func makeUIGestureRecognizer(
        context: Context
    ) -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer()
    }

    func updateUIGestureRecognizer(
        _ recognizer: UIPanGestureRecognizer,
        context: Context
    ) {}

    func handleUIGestureRecognizerAction(
        _ recognizer: UIPanGestureRecognizer,
        context: Context
    ) {
        let state = recognizer.state
        let translation = recognizer.translation(in: recognizer.view).toSize()
        let velocity = recognizer.velocity(in: recognizer.view).toSize()
        let value = Value(translation: translation, velocity: velocity)

        if state == .began || state == .changed {
            onChange(value)
        } else {
            onEnd(value)
        }
    }
}

extension CGPoint {
    func toSize() -> CGSize {
        return .init(width: x, height: y)
    }
}
