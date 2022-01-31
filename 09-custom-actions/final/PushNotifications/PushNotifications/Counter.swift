import Combine

final class Counter: ObservableObject {
  @Published public var accepted = 0
  @Published public var rejected = 0

  static let shared = Counter()

  private init() {}
}
