//
//  Persistence.swift
//  MovieDB
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        try? viewContext.save()
        return result
    }()

    let container: NSPersistentContainer

    /// Error yang mungkin terjadi saat memuat persistent store.
    enum StoreLoadError: Error, LocalizedError {
        case loadFailed(underlying: NSError)
        var errorDescription: String? {
            switch self {
            case .loadFailed(let error):
                return "Gagal memuat database: \(error.localizedDescription). Periksa ruang penyimpanan dan izin."
            }
        }
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MovieDB")
        if inMemory, let description = container.persistentStoreDescriptions.first {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // Jangan pakai fatalError di production. Log dan biarkan app tetap jalan; cache akan kosong.
                #if DEBUG
                print("[Persistence] Store load error: \(error), \(error.userInfo)")
                #endif
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
