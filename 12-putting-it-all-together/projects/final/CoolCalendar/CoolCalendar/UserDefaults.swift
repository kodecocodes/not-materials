import Foundation

extension UserDefaults {
  // swiftlint:disable:next force_unwrapping
  static let appGroup = UserDefaults(suiteName: "group.com.raywenderlich.CoolCalendar")!

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
