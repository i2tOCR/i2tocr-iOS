//
//  OCRObject.swift
//  i2tocr-iOS
//
//  Created by baner on 11/30/25.
//

import UIKit

struct OCRResult: Decodable {
    let language: String
    let config: String
    let text: String
}

struct ServerResponse: Decodable {
    let status: String
    let data: OCRResult
}
