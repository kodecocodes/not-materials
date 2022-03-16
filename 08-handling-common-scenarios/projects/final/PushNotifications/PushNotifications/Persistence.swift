import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  static var preview: PersistenceController = {
    PersistenceController(inMemory: true)
  }()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "Model")

    if inMemory {
      container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }

    print("Loading")
    container.loadPersistentStores { _, error in
      print("Loaded")
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
  }
}
