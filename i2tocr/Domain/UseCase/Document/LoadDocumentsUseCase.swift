//
//  LoadDocumentsUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift

// MARK: - Load Documents
final class LoadDocumentsUseCase {
    private let repository: DocumentRepository
    init(repository: DocumentRepository) {
        self.repository = repository
    }

    func execute() -> Observable<[DocumentObject]> {
        repository.getAllDocuments()
    }
}
