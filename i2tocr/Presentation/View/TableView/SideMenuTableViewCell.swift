//
//  SideMenuTableViewCell.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/18/24.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sideLabel: CLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func viewConfig(sideMenuData: SideMenuItem) {
        sideLabel.text = sideMenuData.title
        if let image = UIImage(systemName: sideMenuData.iconName) {
            iconImageView.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = UIImage(named: sideMenuData.iconName)?.withRenderingMode(.alwaysTemplate)
        }
        iconImageView.tintColor = Colors.Violet
    }
}
