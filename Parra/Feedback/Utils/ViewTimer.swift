//
//  ViewTimer.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/4/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import Foundation

internal typealias ViewTimerCallback = () -> Void
internal class ViewTimerCallbackContainer {
    internal let callback: ViewTimerCallback

    required init(callback: @escaping ViewTimerCallback) {
        self.callback = callback
    }
}

internal protocol ViewTimer: UIView {
    func performAfter(delay: TimeInterval,
                      action: @escaping ViewTimerCallback)

    func cancelTimer()
}

fileprivate struct ViewTimerContext {
    static let references = NSMapTable<UIView, Timer>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
}

internal extension ViewTimer {
    func performAfter(delay: TimeInterval,
                      action: @escaping ViewTimerCallback) {
        Logger.trace("Delayed view action initiated with delay \(delay)")

        cancelTimer()

        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Logger.trace("Performing delayed view action")
            ViewTimerContext.references.removeObject(forKey: self)

            action()
        }

        ViewTimerContext.references.setObject(timer, forKey: self)
    }

    func cancelTimer() {
        if let existingTimer = ViewTimerContext.references.object(forKey: self) {
            Logger.trace("Cancelling existing delayed view action")
            existingTimer.invalidate()
        }
    }
}

