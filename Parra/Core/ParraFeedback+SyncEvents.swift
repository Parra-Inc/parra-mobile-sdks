//
//  ParraFeedback+SyncEvents.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

// When should this happen?
// If there is unsent data and:
// 1. The user answers all of the available questions
// 2. When a ParraFeedbackView is removed from its superview.
// 3. On app did become active
// 4. ...?

extension ParraFeedback {
    func addEventObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(self.triggerSyncFromNotification),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)

        notificationCenter.addObserver(self, selector: #selector(self.triggerSyncFromNotification),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.triggerSyncFromNotification),
                                       name: UIApplication.significantTimeChangeNotification,
                                       object: nil)
    }
    
    func removeEventObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.significantTimeChangeNotification,
                                                  object: nil)
    }
    
    @MainActor
    @objc private func triggerSyncFromNotification(notification: Notification) {
        Task {
            await syncManager.enqueueSync()
        }
    }
}
