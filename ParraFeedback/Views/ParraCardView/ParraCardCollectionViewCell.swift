//
//  ParraCardCollectionViewCell.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 5/16/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

/// A `UICollectionViewCell` subclass used to embed a `ParraCardView` in a `UICollectionView`. Use this as you would any other
/// `UICollectionViewCell` subclass. We also provide `ParraFeedbackCollectionViewCell.defaultCellId` as a sample cell ID to use
/// to register the cell's class with your collection view. Note that using more than one instance of `ParraFeedbackCollectionViewCell` in a collection view
/// is unsupported. Only one should ever be shown.
public class ParraCardCollectionViewCell: UICollectionViewCell {
    
    /// A delegate used to further customize the inner `ParraCardView` and to be informed of actions like when cards change.
    public weak var delegate: ParraCardViewDelegate? {
        get {
            return parraCardView.delegate
        }

        set {
            parraCardView.delegate = newValue
        }
    }

    /// A sample cell ID to use when registering this class with your `UICollectionView`. It is not required that you use this.
    public static let defaultCellId = "ParraFeedbackCollectionViewCell"
    
    /// A `ParraCardViewConfig` used to configure how the wrapper`ParraCardView` looks. Use this to make `ParraCardView`s
    /// blend in with the UI in the rest of your app.
    public var config: ParraCardViewConfig = .default {
        didSet {
            parraCardView.config = config
        }
    }
    
    private let parraCardView = ParraCardView(config: .default)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    /// Used to indicate that the `ParraFeedbackCollectionViewCell` is no longer being displayed. This helps `ParraFeedback` know when
    /// to sync any data that the user provided. In practice, this can be done by implementing the `UICollectionViewDelegate` method `didEndDisplaying`:
    ///
    ///    override func collectionView(_ collectionView: UICollectionView,
    ///                                 didEndDisplaying cell: UICollectionViewCell,
    ///                                 forItemAt indexPath: IndexPath) {
    ///        if let parraCell = cell as? ParraFeedbackCollectionViewCell {
    ///            parraCell.endDisplaying()
    ///        }
    ///    }
    public func endDisplaying() {
        Parra.triggerSync()
    }
    
    private func commonInit() {
        contentView.addSubview(parraCardView)
        
        NSLayoutConstraint.activate([
            parraCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            parraCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            parraCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            parraCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}