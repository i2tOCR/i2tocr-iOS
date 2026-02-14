//
//  UpdateDocumentTextUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift

// MARK: - Update Document Text
final class UpdateDocumentTextUseCase {
    private let repository: DocumentRepository
    init(repository: DocumentRepository) {
        self.repository = repository
    }

    func execute(id: String, newText: String) -> Observable<Bool> {
        repository.updateDocument(id: id, newText: newText)
    }
}
