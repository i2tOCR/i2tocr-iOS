//
//  DocumentRepository.swift
//  i2tocr-iOS
//
//  Created by baner on 11/9/25.
//

import Foundation
import CoreData
import RxSwift
import UIKit

protocol DocumentRepository {
    
    // Fetch all documents
    func getAllDocuments() -> Observable<[DocumentObject]>
    
    // Save a new document
    func saveDocument(_ document: DocumentObject) -> Observable<Bool>
    
    // Delete a document by its ID
    func deleteDocument(id: String) -> Observable<Bool>
    
    // 🚨 NEW: Update the text of an existing document by ID
    func updateDocument(id: String, newText: String) -> Observable<Bool>
    
    // Clear all documents
    func clearAllDocuments() -> Observable<Bool>
}
