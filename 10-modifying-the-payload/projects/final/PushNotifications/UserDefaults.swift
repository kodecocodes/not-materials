import Foundation

extension UserDefaults {
  // 1
  static let suiteName = "group.com.yourcompany.PushNotification"
  static let extensions = UserDefaults(suiteName: suiteName)!
  // 2
  private enum Keys {
    static let badge = "badge"
  }
  // 3
  var badge: Int {
    get { UserDefaults.extensions.integer(forKey: Keys.badge) }
    set { UserDefaults.extensions.set(newValue, forKey: Keys.badge) }
  }
}
