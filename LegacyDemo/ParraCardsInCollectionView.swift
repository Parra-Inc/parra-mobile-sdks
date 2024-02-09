//
//  ParraCardsInCollectionView.swift
//  Demo
//
//  Created by Mick MacCallum on 5/16/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Parra
import UIKit

class ParraCardsInCollectionView: UICollectionViewController,
    UICollectionViewDelegateFlowLayout
{
    // MARK: - Internal

    enum Constant {
        static let feedbackRow = 6
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "demoCell"
        )
        collectionView.register(
            ParraCardCollectionViewCell.self,
            forCellWithReuseIdentifier: ParraCardCollectionViewCell
                .defaultCellId
        )

        if let flowLayout = collectionView?
            .collectionViewLayout as? UICollectionViewFlowLayout
        {
            flowLayout.minimumLineSpacing = 16
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.sectionInset = .init(
                top: 8,
                left: 8,
                bottom: 8,
                right: 8
            )
        }

        ParraFeedback.shared.fetchFeedbackCards { [self] cards, error in
            if let error {
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

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    )
        -> UICollectionViewCell
    {
        if indexPath.row == Constant.feedbackRow, shouldShowFeedback {
            let parraCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ParraCardCollectionViewCell.defaultCellId,
                for: indexPath
            ) as! ParraCardCollectionViewCell

            parraCell.config = .default
            parraCell.delegate = self

            return parraCell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "demoCell",
            for: indexPath
        )

        var contentConfig = UIListContentConfiguration.subtitleCell()

        contentConfig.text = "Demo sample cell #\(indexPath.row)"
        contentConfig.secondaryText = "\(indexPath.row)"
        contentConfig.prefersSideBySideTextAndSecondaryText = true

        cell.contentConfiguration = contentConfig
        cell.backgroundColor = .systemBackground
        cell.layer.cornerRadius = 8

        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return shouldShowFeedback ? 101 : 100
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfColumns: CGFloat = 3
        let availableWidth = collectionView.bounds.width - flowLayout
            .sectionInset.left - flowLayout.sectionInset.right

        if indexPath.row == Constant.feedbackRow, shouldShowFeedback {
            return CGSize(
                width: availableWidth,
                height: ParraCardView.Dimensions.minHeight
            )
        }

        let size = (
            availableWidth - flowLayout
                .minimumInteritemSpacing * (numberOfColumns - 1)
        ) / numberOfColumns
        return CGSize(width: size, height: size)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let parraCell = cell as? ParraCardCollectionViewCell {
            parraCell.endDisplaying()
        }
    }

    // MARK: - Private

    private var shouldShowFeedback = false {
        didSet {
            collectionView.performBatchUpdates { [unowned collectionView] in
                let indexPaths = [IndexPath(
                    row: Constant.feedbackRow,
                    section: 0
                )]

                if shouldShowFeedback {
                    collectionView?.insertItems(at: indexPaths)
                } else {
                    collectionView?.deleteItems(at: indexPaths)
                }
            }
        }
    }
}

// MARK: ParraCardViewDelegate

extension ParraCardsInCollectionView: ParraCardViewDelegate {
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
