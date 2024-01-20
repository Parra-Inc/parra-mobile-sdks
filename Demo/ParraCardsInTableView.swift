//
//  ParraCardsInTableView.swift
//  Demo
//
//  Created by Mick MacCallum on 4/3/22.
//

import UIKit
import Parra

class ParraCardsInTableView: UITableViewController {
    struct Constant {
        static let feedbackRow = 5
    }
    
    private var shouldShowFeedback = false {
        didSet {
            tableView.beginUpdates()
            tableView.reloadRows(
                at: [.init(row: Constant.feedbackRow, section: 0)],
                with: .automatic
            )
            tableView.endUpdates()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ParraCardTableViewCell.self,
                           forCellReuseIdentifier: ParraCardTableViewCell.defaultCellId)

        ParraFeedback.shared.fetchFeedbackCards(appArea: .id("07eb0d9a-4912-46b8-b77e-3741753960ac")) { [self] cards, error in
            if let error = error {
                navigationItem.prompt = "Error fetching Parra cards"
                print("Error fetching Parra cards: \(error)")
            } else if cards.isEmpty {
                navigationItem.prompt = "No Parra cards currently available."
                print("No Parra cards currently available.")
            } else {
                shouldShowFeedback = true
            }
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let parraCell = tableView.dequeueReusableCell(
            withIdentifier: ParraCardTableViewCell.defaultCellId,
            for: indexPath
        ) as? ParraCardTableViewCell, indexPath.row == Constant.feedbackRow && shouldShowFeedback {
            parraCell.config = .default
            parraCell.delegate = self

            return parraCell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "demoCell",
            for: indexPath
        )

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

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView,
                            didEndDisplaying cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if let parraCell = cell as? ParraCardTableViewCell {
            parraCell.endDisplaying()
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ParraCardsInTableView: ParraCardViewDelegate {
    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
        // Allow the user to tap a dismiss button at the end of the Parra Cards.
        shouldShowFeedback = false
    }

    func parraCardViewDidCompleteCollection(_ parraCardView: ParraCardView) {
        // Optionally automatically hide the Parra Feedback View as soon as there have been
        // answers provided for each card.
        // shouldShowFeedback = false
    }
}
