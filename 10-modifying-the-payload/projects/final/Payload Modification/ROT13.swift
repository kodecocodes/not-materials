import Foundation

struct ROT13 {
  static let shared = ROT13()

  private let upper = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  private let lower = Array("abcdefghijklmnopqrstuvwxyz")
  private var mapped: [Character: Character] = [:]

  private init() {
    for i in 0 ..< 26 {
      let idx = (i + 13) % 26
      mapped[upper[i]] = upper[idx]
      mapped[lower[i]] = lower[idx]
    }
  }

  public func decrypt(_ str: String) -> String {
    return String(str.map { mapped[$0] ?? $0 })
  }
}
