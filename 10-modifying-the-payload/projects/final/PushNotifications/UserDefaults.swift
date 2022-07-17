import Foundation

extension UserDefaults {
  static let suiteName = "group.com.raywenderlich.PushNotifications"
  static let extensions = UserDefaults(suiteName: suiteName)!

  private enum Keys {
    static let badge = "badge"
  }

  var badge: Int {
    get { UserDefaults.extensions.integer(forKey: Keys.badge) }
    set { UserDefaults.extensions.set(newValue, forKey: Keys.badge) }
  }
}
