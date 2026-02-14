//
//  CLabel.swift
//  i2tocr-iOS
//
//  Created by bardouei on 12/5/24.
//


import UIKit

class CLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    private func setupLabel() {
        self.textColor = getDynamicTextColor()
        self.font = UIFont(name: Fonts.cruiser, size: 16)
        self.numberOfLines = 0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.textColor = getDynamicTextColor()
    }
    
    private func getDynamicTextColor() -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? Colors.grey1 : Colors.grey6
        }
    }
}
