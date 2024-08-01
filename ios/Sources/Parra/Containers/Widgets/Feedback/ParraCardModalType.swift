//
//  ParraCardModalType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

/// The presentation style to use when presenting Feedback cards modally.
/// `popup` is a similar style to a UIAlertView, where `drawer` is a sheet modal
/// that slides up from the bottom of the screen.
public enum ParraCardModalType: String {
    case popup
    case drawer

    // MARK: - Internal

    // To avoid these values changing unintentionally.
    var eventName: String {
        switch self {
        case .popup:
            return "view:popup"
        case .drawer:
            return "view:drawer"
        }
    }

    var event: ParraDataEvent {
        return ParraCardModalViewedEvent(modalType: self)
    }
}
