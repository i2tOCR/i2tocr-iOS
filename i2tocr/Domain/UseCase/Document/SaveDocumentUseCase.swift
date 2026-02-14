//
//  SaveDocumentUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift

// MARK: - Save Document
final class SaveDocumentUseCase {
    private let repository: DocumentRepository
    init(repository: DocumentRepository) {
        self.repository = repository
    }

    func execute(document: DocumentObject) -> Observable<Bool> {
        repository.saveDocument(document)
    }
}
