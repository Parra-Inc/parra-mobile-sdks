//
//  CAShapeLayer+Extensions.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 12/29/21.
//

import UIKit

internal extension CAShapeLayer {
    func animateStrokeEnd(from: CGFloat, to: CGFloat) {
        self.strokeEnd = from
        self.strokeEnd = to
    }
    
    func animatePath(start: CGPath, end: CGPath) {
        removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = start
        animation.toValue = end
        animation.isRemovedOnCompletion = true
        add(animation, forKey: "pathAnimation")
    }
}
