//
//  CreateDocumentFromOCRUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift


// MARK: - Create Document From OCR
final class CreateDocumentFromOCRUseCase {

    private let saveUseCase: SaveDocumentUseCase

    init(saveUseCase: SaveDocumentUseCase) {
        self.saveUseCase = saveUseCase
    }

    func execute(image: UIImage, recognizedText: String, existingCount: Int, customTitle: String?) -> Observable<Bool> {

        let title = (customTitle?.isEmpty == false) ? customTitle! : "Document \(existingCount + 1)"
        let document = DocumentObject(
            id: UUID().uuidString,
            title: title,
            textDic: recognizedText.isEmpty ? "No text recognized" : recognizedText,
            image: image,
            createdDate: Date()
        )
        return saveUseCase.execute(document: document)
    }
}
