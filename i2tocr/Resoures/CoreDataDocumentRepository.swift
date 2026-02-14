//
//  CoreDataDocumentRepository.swift
//  i2tocr-iOS
//
//  Created by baner on 11/9/25.
//

import CoreData
import UIKit
import RxSwift

// MARK: - Document Repository Implementation
class CoreDataDocumentRepository: DocumentRepository {
    
    private let context: NSManagedObjectContext
    
    init() {
        // Assume CoreDataManager.shared.context provides the main managed object context
        self.context = CoreDataManager.shared.context
        print("📱 CoreDataDocumentRepository initialized")
        CoreDataManager.shared.checkCoreDataStatus() // Assuming this function exists
    }

    // 🚨 IMPLEMENTATION FOR UPDATE METHOD
    func updateDocument(id: String, newText newTitle: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            let context = self.context
            
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "DocumentEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let existingDocuments = try context.fetch(fetchRequest)
                
                guard let entityToUpdate = existingDocuments.first else {
                    print("❌ Document with ID \(id) not found for title update.")
                    observer.onNext(false)
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                entityToUpdate.setValue(newTitle, forKey: "title")
                
                try context.save()
                print("✅ Document title updated successfully for ID: \(id)")
                
                observer.onNext(true)
                observer.onCompleted()
                
            } catch {
                print("❌ Error updating document title for ID \(id): \(error)")
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
// -------------------------------------------------------------------------
    
    func getAllDocuments() -> Observable<[DocumentObject]> {
        return Observable<[DocumentObject]>.create { observer in
            guard self.context.persistentStoreCoordinator != nil else {
                print("❌ PersistentStoreCoordinator is nil in getAllDocuments")
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
            }
            
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "DocumentEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            
            do {
                let entities = try self.context.fetch(request)
                print("📄 Found \(entities.count) documents in Core Data")
                
                let documents = entities.map { entity -> DocumentObject in
                    let id = entity.value(forKey: "id") as? String ?? UUID().uuidString
                    let title = entity.value(forKey: "title") as? String ?? "Untitled"
                    let textDic = entity.value(forKey: "textDic") as? String ?? ""
                    let createdDate = entity.value(forKey: "createdDate") as? Date ?? Date()
                    let imageData = entity.value(forKey: "imageData") as? Data
                    
                    var image: UIImage?
                    if let imageData = imageData {
                        image = UIImage(data: imageData)
                    }
                    
                    return DocumentObject(
                        id: id,
                        title: title,
                        textDic: textDic,
                        image: image,
                        createdDate: createdDate
                    )
                }
                observer.onNext(documents)
                observer.onCompleted()
            } catch {
                print("❌ Error fetching documents: \(error)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func saveDocument(_ document: DocumentObject) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            let context = self.context
            
            guard let coordinator = context.persistentStoreCoordinator else {
                print("❌ PersistentStoreCoordinator is nil - Core Data not properly initialized")
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            guard !coordinator.persistentStores.isEmpty else {
                print("❌ No persistent stores available")
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "DocumentEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", document.id)
            
            do {
                let existingDocuments = try context.fetch(fetchRequest)
                let entity: NSManagedObject
                
                if let existingEntity = existingDocuments.first {
                    entity = existingEntity
                    print("📝 Updating existing document: \(document.id)")
                } else {
                    guard let entityDescription = NSEntityDescription.entity(forEntityName: "DocumentEntity", in: context) else {
                        print("❌ Failed to create entity description")
                        observer.onNext(false)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                    entity = NSManagedObject(entity: entityDescription, insertInto: context)
                    print("🆕 Creating new document: \(document.id)")
                }
                
                entity.setValue(document.id, forKey: "id")
                entity.setValue(document.title, forKey: "title")
                entity.setValue(document.textDic, forKey: "textDic")
                entity.setValue(document.createdDate ?? Date(), forKey: "createdDate")
                
                if let image = document.image {
                    let imageData = image.jpegData(compressionQuality: 0.8)
                    entity.setValue(imageData, forKey: "imageData")
                    print("🖼️ Image data saved: \(imageData?.count ?? 0) bytes")
                }
                
                try context.save()
                print("✅ Document saved successfully: \(document.title)")
                observer.onNext(true)
                observer.onCompleted()
                
            } catch {
                print("❌ Error saving document: \(error)")
                print("Error details: \((error as NSError).userInfo)")
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func deleteDocument(id: String) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "DocumentEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let entities = try self.context.fetch(fetchRequest)
                for entity in entities {
                    self.context.delete(entity)
                }
                try self.context.save()
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                print("Error deleting document: \(error)")
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func clearAllDocuments() -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "DocumentEntity")
            
            do {
                let entities = try self.context.fetch(fetchRequest)
                for entity in entities {
                    self.context.delete(entity)
                }
                try self.context.save()
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                print("Error clearing documents: \(error)")
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
