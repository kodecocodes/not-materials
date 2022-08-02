import CoreData

struct PersistenceController {
  static let shared = PersistenceController()

  static var preview: PersistenceController = {
    PersistenceController(inMemory: true)
  }()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "Model")
    let url: URL
    if inMemory {
      url = URL(fileURLWithPath: "/dev/null")
    } else {
      let groupName = "group.com.yourcompany.PushNotification"
      url = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: groupName)!
        .appendingPathComponent("PushNotifications.sqlite")
    }

    container.persistentStoreDescriptions.first!.url = url

    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
  }
}
