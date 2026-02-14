//
//  CoreDataManager.swift
//  i2tocr-iOS
//
//  Created by baner on 11/9/25.
//
//

import Foundation
import CoreData
import RxSwift

class CoreDataManager {
    
    // MARK: - Singleton Setup
    static let shared = CoreDataManager()
    
    // The container is now a standard, non-lazy constant
    let persistentContainer: NSPersistentContainer
    
    // MARK: - Synchronous Initialization
    
    private init() {
        
        // 1. 🚨 FIX: Manually load the compiled model, checking the correct name
        // We assume the model is named "DocumentModel" (as defined in previous context), not "DocumentModel".
        guard let modelURL = Bundle.main.url(forResource: "DocumentModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            // This fatalError will provide a clear message if the file is missing/misnamed.
            fatalError("❌ FATAL: Core Data model 'DocumentModel.momd' not found in bundle. Ensure name and Target Membership are correct.")
        }
        
        // 2. Initialize the container using the loaded model
        let container = NSPersistentContainer(name: "DocumentModel", managedObjectModel: model)
        
        // --- 🚨 FIX: Synchronous Store Loading using DispatchGroup 🚨 ---
        // This ensures the Core Data stack is ready before the init() completes.
        let group = DispatchGroup()
        group.enter() // Signal that an asynchronous task has begun
        
        // Load persistent stores asynchronously
        container.loadPersistentStores { (storeDescription, error) in
            defer { group.leave() } // Signal that the asynchronous task has finished
            
            if let error = error as NSError? {
                print("❌ Failed to load Core Data: \(error), \(error.userInfo)")
                
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                print("Core Data load error: \(error)")
                #endif
            } else {
                print("✅ Core Data loaded successfully")
            }
        }
        
        // Block the current thread until loadPersistentStores is complete.
        group.wait()
        // --- 🚨 SYNCHRONOUS LOADING FIX END 🚨 ---
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer = container
    }
    
    // MARK: - Context Access
    
    var context: NSManagedObjectContext {
        // Since persistentContainer is now initialized synchronously,
        // this is safe to access immediately.
        return persistentContainer.viewContext
    }
    
    // MARK: - Context Operations
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data context saved successfully")
            } catch {
                print("❌ Failed to save Core Data context: \(error)")
            }
        }
    }
    
    // MARK: - Status Check
    
    func checkCoreDataStatus() {
        let coordinator = persistentContainer.persistentStoreCoordinator
        if coordinator.persistentStores.isEmpty {
            print("❌ No persistent stores found!")
        } else {
            print("✅ Persistent stores: \(coordinator.persistentStores.count)")
        }
    }
}
