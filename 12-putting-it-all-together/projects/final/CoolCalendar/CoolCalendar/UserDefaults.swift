import Foundation

extension UserDefaults {
  static let appGroup = UserDefaults(suiteName: "group.com.gargoylesoft.CoolCalendar")!

  private enum Keys {
    static let badge = "badge"
  }

  var badge: Int {
    get {
      return integer(forKey: Keys.badge)
    } set {
      set(newValue, forKey: Keys.badge)
    }
  }
}
