//
//  ParraFeedbackInTableView.swift
//  Demo
//
//  Created by Mick MacCallum on 4/3/22.
//

import UIKit
import ParraFeedback

class ParraFeedbackInTableView: UITableViewController {
    struct Constant {
        static let feedbackRow = 5
    }
    
    private var shouldShowFeedback = false {
        didSet {
            tableView.beginUpdates()
            tableView.reloadRows(at: [.init(row: Constant.feedbackRow, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ParraFeedbackTableViewCell.self, forCellReuseIdentifier: ParraFeedbackTableViewCell.defaultCellId)
        
        ParraFeedback.fetchFeedbackCards { cards, error in
            if error != nil || cards.isEmpty {
                let text = error != nil ? "Error fetching Parra cards: \(error!)" : "No Parra cards currently available."
                
                self.navigationItem.prompt = text
                
                return
            }

            self.shouldShowFeedback = true
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == Constant.feedbackRow && shouldShowFeedback {
            let parraCell = tableView.dequeueReusableCell(withIdentifier: ParraFeedbackTableViewCell.defaultCellId, for: indexPath)
            
            return parraCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "demoCell", for: indexPath)

        var contentConfig = UIListContentConfiguration.sidebarSubtitleCell()
        
        contentConfig.text = "Demo sample cell #\(indexPath.row)"
        contentConfig.secondaryText = "\(indexPath.row)"
        contentConfig.prefersSideBySideTextAndSecondaryText = true
        
        cell.contentConfiguration = contentConfig
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
