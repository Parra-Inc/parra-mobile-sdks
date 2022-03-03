//
//  ParraRadioButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 12/29/21.
//

import UIKit

fileprivate class RadioLayer: CAShapeLayer {
    var activePath: CGPath?
    var inactivePath: CGPath?
}

class ParraRadioButton: UIButton, SelectableButton {
    enum Style {
        static let outer: CGFloat = 18
        static let inner: CGFloat = 9
        static let lineWidth: CGFloat = 2.5
        static let padding: CGFloat = 6
    }
    
    weak var delegate: SelectableButtonDelegate?
    var allowsDeselection: Bool = false
    var buttonIsSelected: Bool {
        didSet {
            updateSelectionState(animated: true)

            layoutIfNeeded()
        }
    }

    var inactiveColor: UIColor = .lightGray
    
    private var outerLayer = CAShapeLayer()
    private var innerLayer = RadioLayer()

    required init(initiallySelected: Bool) {
        buttonIsSelected = initiallySelected
        
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayer()
        updateSelectionState(animated: false)
    }
    
    func setup() {
        // Add action here
        addTarget(self, action: #selector(selectionAction), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayer()
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    func setupLayer() {
        contentEdgeInsets = UIEdgeInsets(
            top: Style.padding,
            left: Style.outer + Style.padding,
            bottom: Style.padding,
            right: Style.padding
        )
        
        // Add layer here
        func addOuterLayer() {
            outerLayer.strokeColor = tintColor.cgColor
            outerLayer.fillColor = UIColor.clear.cgColor
            outerLayer.lineWidth = Style.lineWidth
            outerLayer.path = UIBezierPath.outerCircle(rect: bounds).cgPath
            outerLayer.removeFromSuperlayer()
            layer.insertSublayer(outerLayer, at: 0)
        }
        
        func addInnerLayer() {
            guard let rect = outerLayer.path?.boundingBox else { return }
            innerLayer.fillColor = tintColor.cgColor
            innerLayer.strokeColor = UIColor.clear.cgColor
            innerLayer.lineWidth = 0
            innerLayer.activePath = UIBezierPath.innerCircleActive(rect: rect).cgPath
            innerLayer.inactivePath = UIBezierPath.innerCircleInactive(rect: rect).cgPath
            innerLayer.path = innerLayer.inactivePath
            innerLayer.removeFromSuperlayer()
            outerLayer.insertSublayer(innerLayer, at: 0)
        }
        
        addOuterLayer()
        addInnerLayer()
    }
    
    @objc func selectionAction(_ sender: ParraRadioButton) {
        if allowsDeselection {
            buttonIsSelected = !buttonIsSelected
        } else if !buttonIsSelected {
            buttonIsSelected = true
        }
                
        if buttonIsSelected {
            delegate?.buttonDidSelect(button: self)
        } else {
            delegate?.buttonDidDeselect(button: self)
        }
    }
    
    func updateSelectionState(animated: Bool) {
        if buttonIsSelected {
            updateActiveLayer(animated: animated)
        } else {
            updateInactiveLayer(animated: animated)
        }
    }

    func updateActiveLayer(animated: Bool) {
        outerLayer.strokeColor = tintColor.cgColor
        
        guard let start = innerLayer.path, let end = innerLayer.activePath else {
            return
        }
        
        if animated {
            innerLayer.animatePath(start: start, end: end)
        }

        innerLayer.path = end
    }
    
    func updateInactiveLayer(animated: Bool) {
        outerLayer.strokeColor = inactiveColor.cgColor
        
        guard let start = innerLayer.path, let end = innerLayer.inactivePath else {
            return
        }
        
        if animated {
            innerLayer.animatePath(start: start, end: end)
        }

        innerLayer.path = end
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
