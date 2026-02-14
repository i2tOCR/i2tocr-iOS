//
//  SearchDocumentsUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift

// MARK: - Search Documents
final class SearchDocumentsUseCase {
    private let repository: DocumentRepository
    init(repository: DocumentRepository) {
        self.repository = repository
    }

    func execute(query: String) -> Observable<[DocumentObject]> {
        repository.getAllDocuments()
            .map { documents in
                guard !query.isEmpty else { return documents }
                return documents.filter {
                    $0.title.localizedCaseInsensitiveContains(query) ||
                    $0.textDic.localizedCaseInsensitiveContains(query)
                }
            }
    }
}
