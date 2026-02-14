//
//  SideMenuItem.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/18/24.
//

import UIKit

// MARK: - SideMenuObject
struct SideMenuItem {
    let title: String
    let iconName: String
    let type: SideMenuItemType
}

enum SideMenuItemType {
    case privacy
    case support
    case logout
    case processingEngine
}
