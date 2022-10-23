//
//  ParraFeedbackTableViewCell.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/29/22.
//

import UIKit
import ParraCore

/// A `UITableViewCell` subclass used to embed a `ParraFeedbackView` in a `UITableView`. Use this as you would any other
/// `UITableViewCell` subclass. We also provide `ParraFeedbackTableViewCell.defaultCellId` as a sample cell ID to use
/// to register the cell's class with your tableview. Note that using more than one instance of `ParraFeedbackTableViewCell` in a table
/// is unsupported. Only one should ever be shown.
public class ParraFeedbackTableViewCell: UITableViewCell {
    
    /// A delegate used to further customize the inner `ParraFeedbackView` and to be informed of actions like when cards change.
    public weak var delegate: ParraFeedbackViewDelegate? {
        get {
            return parraFeedbackView.delegate
        }

        set {
            parraFeedbackView.delegate = newValue
        }
    }
    
    /// A sample cell ID to use when registering this class with your `UITableView`. It is not required that you use this.
    public static let defaultCellId = "ParraFeedbackTableViewCell"
    
    /// A `ParraFeedbackViewConfig` used to configure how the wrapper`ParraFeedbackView` looks. Use this to make `ParraFeedbackView`s
    /// blend in with the UI in the rest of your app.
    public var config: ParraFeedbackViewConfig = .default {
        didSet {
            parraFeedbackView.config = config
        }
    }
    
    private let parraFeedbackView = ParraFeedbackView(config: .default)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    public override var selectionStyle: UITableViewCell.SelectionStyle {
        didSet {
            if selectionStyle != .none {
                selectionStyle = .none
            }
        }
    }
    
    /// Used to indicate that the `ParraFeedbackTableViewCell` is no longer being displayed. This helps `ParraFeedback` know when
    /// to sync any data that the user provided. In practice, this can be done by implementing the `UITableViewDelegate` method `didEndDisplaying`:
    ///
    ///    override func tableView(_ tableView: UITableView,
    ///                            didEndDisplaying cell: UITableViewCell,
    ///                            forRowAt indexPath: IndexPath) {
    ///        if let parraCell = cell as? ParraFeedbackTableViewCell {
    ///            parraCell.endDisplaying()
    ///        }
    ///    }
    public func endDisplaying() {
        Parra.triggerSync()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        contentView.addSubview(parraFeedbackView)
        
        NSLayoutConstraint.activate([
            parraFeedbackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            parraFeedbackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            parraFeedbackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            parraFeedbackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
