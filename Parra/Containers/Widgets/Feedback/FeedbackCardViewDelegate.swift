//
//  FeedbackCardViewDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: Update docs after SwiftUI

/// A delegate for `ParraCardView`s that allows for additional customization,
/// and to be informed of actions such as when particular cards are displayed
/// or when all questions are answered.
public protocol ParraCardViewDelegate: AnyObject {
    /// Asks the delegate to provide a view that can be displayed when all cards
    /// have been completed.
    ///
    /// - Parameter parraCardView: A `ParraCardView` asking the delegate for a
    ///                            complete state view.
    /// - Returns: A `View` shown within the `ParraCardView` when it is in its
    ///            complete state.
    func viewForCompleteState() -> any View

    /// Tells the delegate that every card on the `ParraCardView` has been
    /// completed.
    ///
    /// This delegate method can be useful for hiding the ParraCardView,
    /// since all available cards have been completed.
    ///
    /// - Parameter parraCardView: A `ParraCardView` informing the delegate
    ///                            about the collection completion
    func didCompleteCollection()

    /// Tells the delegate that the `ParraCardView` is about to display the
    /// provided `CardItem`. If no card item is provided, the `ParraCardView`
    /// is transitioning to the complete state.
    ///
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the
    ///                    card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is about to
    ///               be displayed.
    func willDisplay(cardItem: ParraCardItem?)

    /// Tells the delegate that the `ParraCardView` is displaying the provided
    /// `CardItem`. If no card item is provided, the `ParraCardView` is
    /// transitioning to the complete state.
    ///
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the
    ///                    card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is now
    ///               being displayed.
    func didDisplay(cardItem: ParraCardItem?)

    /// Tells the delegate that the `ParraCardView` is about to stop displaying
    /// the provided `CardItem`. If no card item is provided, the
    /// `ParraCardView` is transitioning from the complete state.
    ///
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the
    ///                    card transition.
    ///   - cardItem: The `CardItem` displayed on the card that will no longer
    ///               be displayed.
    func willEndDisplaying(cardItem: ParraCardItem?)

    /// Tells the delegate that the `ParraCardView` has stopped displaying the
    /// provided `CardItem`. If no card item is provided, the `ParraCardView`
    /// is transitioning from the complete state.
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the
    ///                    card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is no longer
    ///               displayed.
    func didEndDisplaying(cardItem: ParraCardItem?)

    /// Asks the delegate whether or not it should automatically navigate to the
    /// provided `CardItem`. This occurs when the user makes a selection on a
    /// card that marks it as complete for the first time and there is a next
    /// card available to transition to.
    ///
    /// - Parameters:
    ///   - parraCardView: The `ParraCardView` asking the delegate whether or
    ///                    not to navigate
    ///                    to the supplied `CardItem`.
    ///   - cardItem: The `CardItem` that will be displayed on the next card.
    /// - Returns: A `Bool` indicating whether or not the automatic
    ///            navigation should occur.
    func shouldAutoNavigateTo(cardItem: ParraCardItem) -> Bool

    /// The ParraCardView has received answers for all of its cards and the user
    /// has selected the dismiss option. Use this event to change any
    /// conditional rendering of the ParraCardView to dismiss it from view.
    ///   - parraCardView: A `ParraCardView` informing the delegate
    ///   dismissal request.
    func didRequestDismissal()
}

public extension ParraCardViewDelegate {
    func viewForCompleteState() -> any View {
        return EmptyView()
    }

    func didCompleteCollection() {}

    func willDisplay(cardItem: ParraCardItem?) {}

    func didDisplay(cardItem: ParraCardItem?) {}

    func willEndDisplaying(cardItem: ParraCardItem?) {}

    func didEndDisplaying(cardItem: ParraCardItem?) {}

    func shouldAutoNavigateTo(cardItem: ParraCardItem) -> Bool {
        return true
    }

    func didRequestDismissal() {}
}
