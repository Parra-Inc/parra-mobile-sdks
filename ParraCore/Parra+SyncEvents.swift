//
//  Parra+SyncEvents.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

internal extension Parra {
    func addEventObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(self.triggerEventualSyncFromNotification),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)

        notificationCenter.addObserver(self, selector: #selector(self.triggerSyncFromNotification),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.triggerEventualSyncFromNotification),
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
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }
        
        Task {
            await syncManager.enqueueSync(with: .immediate)
        }
    }
    
    @MainActor
    @objc private func triggerEventualSyncFromNotification(notification: Notification) {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }
        
        Task {
            await syncManager.enqueueSync(with: .eventual)
        }
    }
}
