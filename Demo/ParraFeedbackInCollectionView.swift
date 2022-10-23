//
//  ParraFeedbackInCollectionView.swift
//  Demo
//
//  Created by Mick MacCallum on 5/16/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraFeedback

class ParraFeedbackInCollectionView: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    struct Constant {
        static let feedbackRow = 6
    }
    
    private var shouldShowFeedback = false {
        didSet {
            collectionView.performBatchUpdates { [unowned collectionView] in
                let indexPaths = [IndexPath(row: Constant.feedbackRow, section: 0)]
                
                if shouldShowFeedback {
                    collectionView?.insertItems(at: indexPaths)
                } else {
                    collectionView?.deleteItems(at: indexPaths)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "demoCell")
        collectionView.register(ParraFeedbackCollectionViewCell.self,
                                forCellWithReuseIdentifier: ParraFeedbackCollectionViewCell.defaultCellId)
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 16
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
        
        ParraFeedback.fetchFeedbackCards { cards, error in
            if let error = error {
                self.navigationItem.prompt = "Error fetching Parra cards"
                print("Error fetching Parra cards: \(error)")
            } else if cards.isEmpty {
                self.navigationItem.prompt = "No Parra cards currently available."
                print("No Parra cards currently available.")
            } else {
                self.shouldShowFeedback = true
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == Constant.feedbackRow && shouldShowFeedback {
            let parraCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ParraFeedbackCollectionViewCell.defaultCellId,
                for: indexPath
            ) as! ParraFeedbackCollectionViewCell
            
            parraCell.config = .default
            parraCell.delegate = self
            
            return parraCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "demoCell", for: indexPath)

        var contentConfig = UIListContentConfiguration.subtitleCell()
        
        contentConfig.text = "Demo sample cell #\(indexPath.row)"
        contentConfig.secondaryText = "\(indexPath.row)"
        contentConfig.prefersSideBySideTextAndSecondaryText = true
        
        cell.contentConfiguration = contentConfig
        cell.backgroundColor = .init(white: 0.95, alpha: 1.0)
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return shouldShowFeedback ? 101 : 100
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfColumns: CGFloat = 3
        let availableWidth = collectionView.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        if indexPath.row == Constant.feedbackRow && shouldShowFeedback {
            return CGSize(width: availableWidth, height: ParraFeedbackView.Dimensions.minHeight)
        }
        
        let size = (availableWidth - flowLayout.minimumInteritemSpacing * (numberOfColumns - 1)) / numberOfColumns
        return CGSize(width: size, height: size)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if let parraCell = cell as? ParraFeedbackCollectionViewCell {
            parraCell.endDisplaying()
        }
    }
}

extension ParraFeedbackInCollectionView: ParraFeedbackViewDelegate {
    func parraFeedbackViewDidRequestDismissal(_ parraFeedbackView: ParraFeedbackView) {
        // Allow the user to tap a dismiss button at the end of the Parra Cards.
        shouldShowFeedback = false
    }

    func parraFeedbackViewDidCompleteCollection(_ parraFeedbackView: ParraFeedbackView) {
        // Optionally automatically hide the Parra Feedback View as soon as there have been
        // answers provided for each card.
        // shouldShowFeedback = false
    }
}
