//
//  CImageView.swift
//  i2tocr-iOS
//
//  Created by bardouei on 12/5/24.
//


import UIKit

@IBDesignable
class CImageView: UIImageView {
    
    // MARK: - Inspectable Properties
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGPoint = CGPoint.zero {
        didSet {
            layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var contentModeType: String = "scaleAspectFit" {
        didSet {
            switch contentModeType.lowercased() {
            case "scaleaspectfit":
                contentMode = .scaleAspectFit
            case "scaleaspectfill":
                contentMode = .scaleAspectFill
            case "scaletofill":
                contentMode = .scaleToFill
            default:
                contentMode = .scaleAspectFit
            }
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.masksToBounds = true
    }
    
    // MARK: - Public Methods
    
    /// Loads an image from a URL asynchronously.
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil,
                  let downloadedImage = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }
        task.resume()
    }
}
