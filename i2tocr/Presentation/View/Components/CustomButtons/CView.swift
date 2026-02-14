//
//  CView.swift
//  i2tocr-iOS
//
//  Created by bardouei on 12/5/24.
//


import UIKit

class CView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = getDynamicBackgroundColor()
        self.layer.cornerRadius = 16
        self.layer.borderColor = Colors.Violet.cgColor
        self.layer.shadowColor = Colors.Violet.cgColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.backgroundColor = getDynamicBackgroundColor()
    }
    
    private func getDynamicBackgroundColor() -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? Colors.grey6 : Colors.grey1
        }
    }
}
