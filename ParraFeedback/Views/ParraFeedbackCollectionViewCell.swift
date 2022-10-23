//
//  ParraFeedbackCollectionViewCell.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 5/16/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

/// A `UICollectionViewCell` subclass used to embed a `ParraFeedbackView` in a `UICollectionView`. Use this as you would any other
/// `UICollectionViewCell` subclass. We also provide `ParraFeedbackCollectionViewCell.defaultCellId` as a sample cell ID to use
/// to register the cell's class with your collection view. Note that using more than one instance of `ParraFeedbackCollectionViewCell` in a collection view
/// is unsupported. Only one should ever be shown.
public class ParraFeedbackCollectionViewCell: UICollectionViewCell {
    
    /// A delegate used to further customize the inner `ParraFeedbackView` and to be informed of actions like when cards change.
    public weak var delegate: ParraFeedbackViewDelegate? {
        get {
            return parraFeedbackView.delegate
        }

        set {
            parraFeedbackView.delegate = newValue
        }
    }

    /// A sample cell ID to use when registering this class with your `UICollectionView`. It is not required that you use this.
    public static let defaultCellId = "ParraFeedbackCollectionViewCell"
    
    /// A `ParraFeedbackViewConfig` used to configure how the wrapper`ParraFeedbackView` looks. Use this to make `ParraFeedbackView`s
    /// blend in with the UI in the rest of your app.
    public var config: ParraFeedbackViewConfig = .default {
        didSet {
            parraFeedbackView.config = config
        }
    }
    
    private let parraFeedbackView = ParraFeedbackView(config: .default)
    
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
        contentView.addSubview(parraFeedbackView)
        
        NSLayoutConstraint.activate([
            parraFeedbackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            parraFeedbackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            parraFeedbackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            parraFeedbackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
