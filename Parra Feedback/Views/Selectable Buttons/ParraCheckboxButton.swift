//
//  ParraCheckboxButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 12/29/21.
//

import UIKit

class ParraCheckboxButton: UIButton, SelectableButton {
    enum Style {
        static let height: CGFloat = 18.0
        static let lineWidth: CGFloat = 2.0
        static let padding: CGFloat = 6.0
        static let cornerRadius: CGFloat = 2.0
    }
    
    weak var delegate: SelectableButtonDelegate?
    var allowsDeselection: Bool = true
    var buttonIsSelected: Bool = false {
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

    var inactiveColor: UIColor = .clear
    var inactiveBorderColor: UIColor = .lightGray
    var checkMarkColor: UIColor = .white
    
    private var outerLayer = CAShapeLayer()
    private var checkMarkLayer = CAShapeLayer()

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public convenience init?(type buttonType: UIButton.ButtonType) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayer()
        updateSelectionState()
    }
    
    func setup() {
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
    
    @objc func selectionAction(_ sender: ParraRadioButton) {
        if allowsDeselection {
            buttonIsSelected = !buttonIsSelected
        } else if !buttonIsSelected {
            buttonIsSelected = true
        }
    }
    
    func updateSelectionState() {
        if buttonIsSelected {
            updateActiveLayer()
        } else {
            updateInactiveLayer()
        }
    }

    func updateActiveLayer() {
        checkMarkLayer.animateStrokeEnd(from: 0, to: 1)
        outerLayer.fillColor = tintColor.cgColor
        outerLayer.strokeColor = tintColor.cgColor
    }
    
    func updateInactiveLayer() {
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
