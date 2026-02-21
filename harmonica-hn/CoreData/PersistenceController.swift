import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HarmonicHN")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        let c = container
        
        c.loadPersistentStores { description, error in
            if let error = error {
                print("⚠️ Core Data failed: \(error). Wiping and retrying...")
                
                // Delete corrupt store
                if let storeURL = description.url {
                    try? FileManager.default.removeItem(at: storeURL)
                }
                
                // Retry once with clean store
                c.loadPersistentStores { _, retryError in
                    if let retryError = retryError {
                        fatalError("❌ Core Data unrecoverable: \(retryError)")
                    } else {
                        print("✅ Core Data recovered successfully")
                    }
                }
            } else {
                print("✅ Core Data loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var backgroundContext: NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
    
    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()
}
