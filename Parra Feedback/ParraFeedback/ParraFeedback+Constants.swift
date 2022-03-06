//
//  ParraFeedback+Constants.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

extension ParraFeedback {
    enum Constant {
        static let parraBundle = Bundle(for: ParraFeedback.self)
        static let parraLogPrefix = "[PARRA FEEDBACK]"
        static let parraApiRoot = URL(string: "https://api.parra.io/v1/")!
    }
    
    enum Queue {
        static let sync = DispatchQueue(
            label: "com.parra.feedback.dataQueue",
            qos: .utility
        )
    }
}
