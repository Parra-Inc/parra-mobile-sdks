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
        let bundle = ParraFeedback.bundle()
        
        guard let url = bundle.url(
            forResource: "Parra\(ParraFeedback.name)",
            withExtension: "bundle"
        ) else {
            return nil
        }
        
        return UIImage(
            named: name,
            in: Bundle(url: url),
            with: nil
        )
    }
}
