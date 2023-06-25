//
//  ParraConfigurableView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/19/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

internal protocol ParraConfigurableView: AnyObject {
    func applyConfig(_ config: ParraCardViewConfig)
}
