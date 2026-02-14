//
//  DocumentObject.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/18/24.
//

import UIKit

class DocumentObject {
    let id: String
    var title: String
    var textDic: String
    let image: UIImage?
    let createdDate: Date?
    
    init(id: String, title: String, textDic: String, image: UIImage? = nil, createdDate: Date? = nil) {
        self.id = id
        self.title = title
        self.textDic = textDic
        self.image = image
        self.createdDate = createdDate
    }
}

