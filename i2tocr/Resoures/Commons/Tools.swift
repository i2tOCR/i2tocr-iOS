//
//  Tools.swift
//  i2tocr-iOS
//
//  Created by bardouei on 7/12/24.
//
//
import UIKit

//MARK: - Device
struct ScreenSize {
    static let SCREEN_WIDTH      = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT     = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

final class PaddingRegularLabel: UILabel {
    
     var topInset   : CGFloat = 0
     var bottomInset: CGFloat = 0
     var leftInset  : CGFloat = 0
     var rightInset : CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont(name: Fonts.cruiser , size: (self.font.pointSize))
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
    
    func setPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat){
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
    }
}
