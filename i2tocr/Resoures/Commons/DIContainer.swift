//
//  DIContainer.swift
//  i2tocr-iOS
//
//  Created by bardouei on 7/12/24.
//

import Foundation
import Swinject
import SwinjectAutoregistration
import RxSwift
import UIKit

final class DIContainer {
    static let sharedInstance = DIContainer()

    let container: Container

    private init() {
        self.container = Container()
        setContainers()
    }

    func setContainers() {

        // MARK: - Repository
        container.register(DocumentRepository.self) { _ in
            CoreDataDocumentRepository()
        }
        .inObjectScope(.container)

        // MARK: - UseCases (Document)
        container.register(LoadDocumentsUseCase.self) { r in
            LoadDocumentsUseCase(repository: r.resolve(DocumentRepository.self)!)
        }

        container.register(SaveDocumentUseCase.self) { r in
            SaveDocumentUseCase(repository: r.resolve(DocumentRepository.self)!)
        }

        container.register(DeleteDocumentUseCase.self) { r in
            DeleteDocumentUseCase(repository: r.resolve(DocumentRepository.self)!)
        }

        container.register(UpdateDocumentTextUseCase.self) { r in
            UpdateDocumentTextUseCase(repository: r.resolve(DocumentRepository.self)!)
        }

        container.register(SearchDocumentsUseCase.self) { r in
            SearchDocumentsUseCase(repository: r.resolve(DocumentRepository.self)!)
        }

        container.register(CreateDocumentFromOCRUseCase.self) { r in
            CreateDocumentFromOCRUseCase(
                saveUseCase: r.resolve(SaveDocumentUseCase.self)!
            )
        }

        // MARK: - UseCases (Engine)
        container.register(GetCurrentEngineUseCase.self) { _ in
            GetCurrentEngineUseCase()
        }

        container.register(ToggleProcessingEngineUseCase.self) { _ in
            ToggleProcessingEngineUseCase()
        }

        // MARK: - ViewModel
        container.register(HomeViewModel.self) { r in
            HomeViewModel(
                loadDocuments: r.resolve(LoadDocumentsUseCase.self)!,
                saveDocument: r.resolve(SaveDocumentUseCase.self)!,
                deleteDocument: r.resolve(DeleteDocumentUseCase.self)!,
                updateDocument: r.resolve(UpdateDocumentTextUseCase.self)!,
                searchDocuments: r.resolve(SearchDocumentsUseCase.self)!,
                createFromOCR: r.resolve(CreateDocumentFromOCRUseCase.self)!,
                getEngine: r.resolve(GetCurrentEngineUseCase.self)!,
                toggleEngine: r.resolve(ToggleProcessingEngineUseCase.self)!
            )
        }
        .inObjectScope(.container)

        // MARK: - Navigator
        container.register(HomeNavigator.self) { _ in
            HomeNavigatorRoute.sharedInstance
        }
        .inObjectScope(.container)
    }

    func getContainer<T>(type: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            fatalError("Failed to resolve \(T.self)")
        }
        return resolved
    }
}

import Foundation

@propertyWrapper
struct Inject<T> {
    var wrappedValue: T

    init() {
        self.wrappedValue = DIContainer.sharedInstance.getContainer(type: T.self)
    }
}
