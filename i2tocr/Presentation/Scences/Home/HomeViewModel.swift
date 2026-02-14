//
// HomeViewModel.swift
// i2tocr-iOS
//
// Created by bardouei on 8/18/24.
//
//

import RxSwift
import RxCocoa
import UIKit

final class HomeViewModel: BaseViewModel {

    // MARK: - State
    enum DocumentChangeState {
        case documentsLoaded
        case documentSaved
        case documentUpdated
        case documentDeleted
        case serverMessage(String)
        case error(String)
    }

    // MARK: - Outputs
    let documents = BehaviorRelay<[DocumentObject]>(value: [])
    let state = PublishSubject<DocumentChangeState>()

    // MARK: - Dependencies
    private let loadDocuments: LoadDocumentsUseCase
    private let saveDocument: SaveDocumentUseCase
    private let deleteDocument: DeleteDocumentUseCase
    private let updateDocument: UpdateDocumentTextUseCase
    private let searchDocuments: SearchDocumentsUseCase
    private let createFromOCR: CreateDocumentFromOCRUseCase
    private let getEngine: GetCurrentEngineUseCase
    private let toggleEngine: ToggleProcessingEngineUseCase

    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        loadDocuments: LoadDocumentsUseCase,
        saveDocument: SaveDocumentUseCase,
        deleteDocument: DeleteDocumentUseCase,
        updateDocument: UpdateDocumentTextUseCase,
        searchDocuments: SearchDocumentsUseCase,
        createFromOCR: CreateDocumentFromOCRUseCase,
        getEngine: GetCurrentEngineUseCase,
        toggleEngine: ToggleProcessingEngineUseCase
    ) {
        self.loadDocuments = loadDocuments
        self.saveDocument = saveDocument
        self.deleteDocument = deleteDocument
        self.updateDocument = updateDocument
        self.searchDocuments = searchDocuments
        self.createFromOCR = createFromOCR
        self.getEngine = getEngine
        self.toggleEngine = toggleEngine
    }

    // MARK: - Engine
    var currentEngineName: String {
        getEngine.execute().displayName
    }

    func toggleProcessingEngine() {
        _ = toggleEngine.execute(current: getEngine.execute())
    }

    // MARK: - Documents
    func loadAllDocuments() {
        loadDocuments.execute()
            .subscribe(onNext: { [weak self] docs in
                self?.documents.accept(docs)
                self?.state.onNext(.documentsLoaded)
            }, onError: { [weak self] error in
                self?.state.onNext(.error(error.localizedDescription))
            })
            .disposed(by: disposeBag)
    }

    func save(document: DocumentObject) {
        saveDocument.execute(document: document)
            .subscribe(onNext: { [weak self] success in
                success ? self?.loadAllDocuments()
                        : self?.state.onNext(.error("Save failed"))
                self?.state.onNext(.documentSaved)
            })
            .disposed(by: disposeBag)
    }

    func delete(id: String) {
        deleteDocument.execute(id: id)
            .subscribe(onNext: { [weak self] success in
                success ? self?.loadAllDocuments()
                        : self?.state.onNext(.error("Delete failed"))
                self?.state.onNext(.documentDeleted)
            })
            .disposed(by: disposeBag)
    }

    func updateText(id: String, text: String) {
        updateDocument.execute(id: id, newText: text)
            .subscribe(onNext: { [weak self] success in
                success ? self?.state.onNext(.documentUpdated)
                        : self?.state.onNext(.error("Update failed"))
            })
            .disposed(by: disposeBag)
    }

    func search(query: String) {
        searchDocuments.execute(query: query)
            .subscribe(onNext: { [weak self] docs in
                self?.documents.accept(docs)
            })
            .disposed(by: disposeBag)
    }

    func createDocumentFromOCR(
        image: UIImage,
        recognizedText: String,
        customTitle: String?
    ) {
        createFromOCR.execute(
            image: image,
            recognizedText: recognizedText,
            existingCount: documents.value.count,
            customTitle: customTitle
        )
        .subscribe(onNext: { [weak self] success in
            success ? self?.loadAllDocuments()
                    : self?.state.onNext(.error("OCR create failed"))
        })
        .disposed(by: disposeBag)
    }
}
