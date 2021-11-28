//
//  ParraCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit

class ParraQuestionCardView: ParraCardView {
    let question: ParraFeedbackQuestion?

    required init(question: ParraFeedbackQuestion?) {
        self.question = question
                
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: .zero)
        
        if let question = question {
            label.text = question.title
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
