//
//  ParraFeedback+SyncEvents.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/4/22.
//

import Foundation
import UIKit

extension ParraFeedback {
    func addEventObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            self.triggerSync()
        }
    }
    
    func removeEventObservers() {
        NotificationCenter.default.removeObserver(self)
    }
 
    private func triggerSync() {
        // TODO: Can we ensure that if the app launches, and there is data to sync, that the data
        // TODO: sync occurs before fetching the new data?
        
        // When should this happen?
        // If there is unsent data and:
        // 1. The user answers all of the available questions
        // 2. When a ParraFeedbackView is removed from its superview.
        // 3. On app entered foreground
    }
    
    private func submitCurrentData() async throws {
        // Temporarily get answers, loop through them and send answer.
        
        
        //        let response: SOME_CLASS = try await shared.performAuthenticatedRequest(
        //            route: "bulk/sessions",
        //            method: .put,
        //            authenticationProvider: shared.refreshAuthentication
        //        )
    }

}
