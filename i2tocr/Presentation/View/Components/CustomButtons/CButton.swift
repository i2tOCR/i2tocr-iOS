//
//  CButton.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/18/24.
//


import UIKit

@IBDesignable class CButton: UIButton {
    
    private var _imagePosition:LXMImagePosition = .left
    
    @IBInspectable  var spacing:CGFloat = 0 {
        didSet{
            setupImage()
        }
    }
    
    @IBInspectable  var imagePosition:String = "left" {
        didSet {
            switch imagePosition.uppercased() {
            case "LEFT":
                _imagePosition = .left
            case "RIGHT":
                _imagePosition = .right
            case "TOP":
                _imagePosition = .top
            case "BOTTOM":
                _imagePosition = .bottom
            default:
                _imagePosition = .left
            }
            setupImage()
            
        }
    }
    
    @IBInspectable  var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable  var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            
        }
    }
    
    @IBInspectable  var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    
    @IBInspectable  var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
            
        }
    }
    @IBInspectable  var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
            
        }
    }
    @IBInspectable  var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
            
        }
    }
    
    @IBInspectable  var shadowOffset: CGPoint = CGPoint.zero{
        didSet {
            layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
            
        }
    }
    
    @IBInspectable  var clipBounds: Bool = true {
        didSet{
            clipsToBounds = clipBounds
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImage()
    }
    
    func setupImage()  {
        setImagePeraperty()
    }
    
    enum LXMImagePosition:Int {
        case left = 0
        case right = 1
        case top = 2
        case bottom = 3
    }
    
    override func tintColorDidChange() {
        tintColor = Colors.clear
    }
    
    func setImagePeraperty() {
        self.backgroundColor = Colors.Violet
        self.titleLabel?.font = UIFont(name: Fonts.cruiser, size: 14)
        self.layer.cornerRadius = 20
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setTitleColor(getDynamicTextColor(), for: .normal)
    }
    
    private func getDynamicTextColor() -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? Colors.grey1 : Colors.white
        }
    }
}
