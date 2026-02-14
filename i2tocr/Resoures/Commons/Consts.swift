//
//  Consts.swift
//  i2tocr-iOS
//
//  Created by bardouei on 7/12/24.
//

import UIKit
import SwiftyUserDefaults

struct General {
    static let ERROR_401_HAPPENED    = NSNotification.Name(rawValue: "ERROR_401_HAPPENED")
    
    static let ERROR_403_HAPPENED    = NSNotification.Name(rawValue: "ERROR_403_HAPPENED")
    
    static let ERROR_404_HAPPENED    = NSNotification.Name(rawValue: "ERROR_404_HAPPENED")
    
    static let ERROR_500_HAPPENED    = NSNotification.Name(rawValue: "ERROR_500_HAPPENED")
    
    static let ERROR_ProfileNotFound_HAPPENED = NSNotification.Name(rawValue: "ERROR_ProfileNotFound_HAPPENED")
}

// Fonts
struct Fonts {
    static let sevenSegment = "Open24DisplaySt"
    static let cruiser = "2015Cruiser"
}

// Colors
struct Colors {
    static let white           = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let black           = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let clear           = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    static let grey1           = #colorLiteral(red: 0.8972938657, green: 0.8972938657, blue: 0.8972938657, alpha: 1)
    static let grey2           = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    static let grey3           = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
    static let grey4           = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    static let grey5           = #colorLiteral(red: 0.2156862745, green: 0.2196078431, blue: 0.2431372549, alpha: 1)
    static let grey6           = #colorLiteral(red: 0.1333333333, green: 0.137254902, blue: 0.1529411765, alpha: 1)
    static let grey7           = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
    static let grey9           = #colorLiteral(red: 0.3647058824, green: 0.3450980392, blue: 0.3294117647, alpha: 1)
    
    static let lightBlue       = #colorLiteral(red: 0.431372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let blue            = #colorLiteral(red: 0.09803921569, green: 0.5764705882, blue: 1, alpha: 1)
    static let highlightedBlue = #colorLiteral(red: 0.003921568627, green: 0.4352941176, blue: 0.8470588235, alpha: 1)
    static let green           = #colorLiteral(red: 0.6, green: 0.7568627451, blue: 0.3019607843, alpha: 1)
    static let darkGreen       = #colorLiteral(red: 0.4509803922, green: 0.568627451, blue: 0.2274509804, alpha: 1)
    static let yellow          = #colorLiteral(red: 1, green: 0.768627451, blue: 0, alpha: 1)
    static let orange          = #colorLiteral(red: 0.9411764706, green: 0.5176470588, blue: 0.3254901961, alpha: 1)
    static let lightRed        = #colorLiteral(red: 0.9209958911, green: 0.6254754663, blue: 0.6171939373, alpha: 1)
    static let red             = #colorLiteral(red: 0.8509803922, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
    static let darkRed         = #colorLiteral(red: 0.6705882353, green: 0.2823529412, blue: 0.2823529412, alpha: 1)
    
    static let grayLight       = #colorLiteral(red: 0.6078431373, green: 0.6196078431, blue: 0.6784313725, alpha: 1)
    static let perpulr         = #colorLiteral(red: 0.5529411765, green: 0.4470588235, blue: 1, alpha: 1)
    static let redDark         = #colorLiteral(red: 0.7019607843, green: 0.0431372549, blue: 0, alpha: 1)
    
    static let greenBlue       = #colorLiteral(red: 0, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
    
    static let Violet          = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
}

extension DefaultsKeys {
    var isDarkModeEnabled: DefaultsKey<Bool> { .init("isDarkModeEnabled", defaultValue: false) }
    var isAuthenticated: DefaultsKey<Bool> { .init("isAuthenticated", defaultValue: false) }
    var hasSeenIntro: DefaultsKey<Bool> { .init("hasSeenIntro", defaultValue: false) }
}
