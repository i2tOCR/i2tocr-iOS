//
//  DeleteDocumentUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift

// MARK: - Delete Document
final class DeleteDocumentUseCase {
    private let repository: DocumentRepository
    init(repository: DocumentRepository) {
        self.repository = repository
    }

    func execute(id: String) -> Observable<Bool> {
        repository.deleteDocument(id: id)
    }
}
