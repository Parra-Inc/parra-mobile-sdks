//
//  ParraDemoTableViewController.swift
//  Parra Feedback SDK Demo
//
//  Created by Mick MacCallum on 3/6/22.
//

import UIKit
import ParraCore
import ParraFeedback

class ParraDemoTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Parra.hasAuthenticationProvider() {
            navigationItem.prompt = "ParraFeedback not configured!"
        }
    }
}
