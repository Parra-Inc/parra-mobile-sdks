//
//  ParraFeedbackForm.swift
//  Demo
//
//  Created by Mick MacCallum on 6/7/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore
import ParraFeedback

class ParraFeedbackForm: UIViewController {
    @IBOutlet weak var presentFormButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    private var formData: ParraFeedbackFormResponse?

    override func viewDidLoad() {
        super.viewDidLoad()

        presentFormButton.isEnabled = false

        ParraFeedback.fetchFeedbackForm(formId: "c15256c2-d21d-4d9f-85ac-1d4655416a95") { [self] response in
            switch response {
            case .success(let data):
                formData = data
                presentFormButton.isEnabled = true
            case .failure(let error):
                errorLabel.text = error.localizedDescription
            }
        }
    }

    @IBAction func presentFeedbackForm(_ sender: UIButton) {
        guard let formData else {
            return
        }

        ParraFeedback.presentFeedbackForm(with: formData, from: self)
    }
}
