//
//  MyScanCollectionViewCell.swift
//  i2tocr-iOS
//
//  Created by bardouei on 12/6/24.
//

import UIKit

class MyScanCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var scanImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSelectionIndicator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSelectionIndicator()
    }
    
    func configure(with document: DocumentObject) {
        nameTitleLabel.text = document.title
        nameTitleLabel.textColor = Colors.white
        
        // 1. Configure backView properties
        backView.layer.cornerRadius = 10
        backView.backgroundColor = Colors.grey5
        
        // 2. Add the shadow
        addShadow() // <-- Call the new function here
        
        scanImageView.image = document.image
        scanImageView.contentMode = .scaleAspectFill
        scanImageView.clipsToBounds = true
        scanImageView.layer.cornerRadius = 10
    }
    
    private func addShadow() {
        backView.layer.masksToBounds = false
        backView.layer.shadowOpacity = 0.4
        backView.layer.shadowRadius = 8
        backView.layer.shadowOffset = CGSize(width: 0, height: 4)
        backView.layer.shadowColor = UIColor.black.cgColor
        backView.layer.shouldRasterize = true
        backView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private let selectionIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
    
    private func setupSelectionIndicator() {
        contentView.addSubview(selectionIndicator)
        
        NSLayoutConstraint.activate([
            selectionIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            selectionIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func showSelectionIndicator(isSelected: Bool) {
        selectionIndicator.isHidden = false
        selectionIndicator.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
        selectionIndicator.tintColor = isSelected ? .systemBlue : .systemGray
    }
    
    func hideSelectionIndicator() {
        selectionIndicator.isHidden = true
    }
}
