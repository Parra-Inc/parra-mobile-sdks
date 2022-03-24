//
//  UIImage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

extension UIImage {
    static func parraImageNamed(_ name: String) -> UIImage? {
        print(ParraFeedback.bundle())
        
        return UIImage(
            named: name,
            in: nil,
            with: nil
        )
    }
}
