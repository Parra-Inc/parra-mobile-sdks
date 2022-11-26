//
//  ParraCheckboxButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 12/29/21.
//

import UIKit
import ParraCore

internal class ParraCheckboxButton: UIButton, SelectableButton {
    enum Style {
        static let height: CGFloat = 18.0
        static let lineWidth: CGFloat = 2.0
        static let padding: CGFloat = 6.0
        static let cornerRadius: CGFloat = 2.0
    }
    
    internal weak var delegate: SelectableButtonDelegate?
    internal var allowsDeselection: Bool = true
    internal var buttonIsSelected: Bool {
        didSet {
            if buttonIsSelected == oldValue {
                return
            }
            
            updateSelectionState()
            
            if buttonIsSelected {
                delegate?.buttonDidSelect(button: self)
            } else {
                delegate?.buttonDidDeselect(button: self)
            }
        }
    }
    
    internal var inactiveColor: UIColor = .clear
    internal var inactiveBorderColor: UIColor = .lightGray
    internal var checkMarkColor: UIColor = .white
    
    private var outerLayer = CAShapeLayer()
    private var checkMarkLayer = CAShapeLayer()
    
    internal required init(initiallySelected: Bool, config: ParraCardViewConfig, asset: Asset?) {
        buttonIsSelected = initiallySelected
        super.init(frame: .zero)
        setup()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayer()
        updateSelectionState()
    }
    
    internal func setup() {
        addTarget(self, action: #selector(selectionAction), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayer()
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    internal func setupLayer() {
        contentEdgeInsets = UIEdgeInsets(
            top: Style.padding,
            left: Style.height + Style.padding,
            bottom: Style.padding,
            right: Style.padding
        )
        
        let origin = CGPoint(
            x: Style.padding + 2,
            y: bounds.midY - Style.height / 2.0
        )
        
        let size = CGSize(
            width: Style.height,
            height: Style.height
        )
        
        let rect = CGRect(
            origin: origin,
            size: size
        )
        
        outerLayer.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: Style.cornerRadius
        ).cgPath
        outerLayer.lineWidth = Style.lineWidth
        outerLayer.removeFromSuperlayer()
        
        layer.insertSublayer(outerLayer, at: 0)
        
        let path = UIBezierPath()
        var xPos = origin.x + Style.lineWidth
        var yPos = rect.midY
        
        path.move(to: CGPoint(x: xPos, y: yPos))
        
        var checkMarkLength = rect.width - xPos - Style.lineWidth
        
        [45.0, -45.0].forEach {
            xPos = xPos + checkMarkLength * cos($0 * .pi / 180.0)
            yPos = yPos + checkMarkLength * sin($0 * .pi / 180.0)
            
            path.addLine(to: CGPoint(x: xPos, y: yPos))
            
            checkMarkLength *= 2
        }
        
        checkMarkLayer.lineWidth = Style.lineWidth
        checkMarkLayer.strokeColor = checkMarkColor.cgColor
        checkMarkLayer.path = path.cgPath
        checkMarkLayer.fillColor = UIColor.clear.cgColor
        checkMarkLayer.removeFromSuperlayer()
        outerLayer.insertSublayer(checkMarkLayer, at: 0)
    }
    
    @objc internal  func selectionAction(_ sender: ParraRadioButton) {
        if allowsDeselection {
            buttonIsSelected = !buttonIsSelected
        } else if !buttonIsSelected {
            buttonIsSelected = true
        }
    }
    
    internal func updateSelectionState() {
        if buttonIsSelected {
            updateActiveLayer()
        } else {
            updateInactiveLayer()
        }
    }
    
    internal func updateActiveLayer() {
        checkMarkLayer.animateStrokeEnd(from: 0, to: 1)
        outerLayer.fillColor = tintColor.cgColor
        outerLayer.strokeColor = tintColor.cgColor
    }
    
    internal func updateInactiveLayer() {
        checkMarkLayer.animateStrokeEnd(from: 1, to: 0)
        outerLayer.fillColor = inactiveColor.cgColor
        outerLayer.strokeColor = inactiveBorderColor.cgColor
    }
}

private extension UIBezierPath {
    static func outerCircle(rect: CGRect) -> UIBezierPath {
        let size = CGSize(
            width: ParraRadioButton.Style.outer,
            height: ParraRadioButton.Style.outer
        )
        
        let origin = CGPoint(
            x: ParraRadioButton.Style.lineWidth / 2.0 + ParraRadioButton.Style.padding,
            y: rect.size.height / 2.0 - ParraRadioButton.Style.outer / 2.0
        )
        
        let newRect = CGRect(
            origin: origin,
            size: size
        )
        
        return UIBezierPath(
            roundedRect: newRect,
            cornerRadius: size.height / 2.0
        )
    }
    
    static func innerCircleActive(rect: CGRect) -> UIBezierPath {
        let size = CGSize(
            width: ParraRadioButton.Style.inner,
            height: ParraRadioButton.Style.inner
        )
        
        let origin = CGPoint(
            x: rect.midX - size.width / 2.0,
            y: rect.midY - size.height / 2.0
        )
        
        let newRect = CGRect(
            origin: origin,
            size: size
        )
        
        return UIBezierPath(
            roundedRect: newRect,
            cornerRadius: size.height / 2.0
        )
    }
    
    /// Get inner circle layer for inactive state
    static func innerCircleInactive(rect: CGRect) -> UIBezierPath {
        let origin = CGPoint(
            x: rect.midX,
            y: rect.midY
        )
        
        let frame = CGRect(
            origin: origin,
            size: CGSize.zero
        )
        
        return UIBezierPath(rect: frame)
    }
}
