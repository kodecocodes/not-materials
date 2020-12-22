import Foundation

struct TokenDetails {
  private let encoder = JSONEncoder()
  let token: String
  var debug = false

  init(token: Data) {
    self.token = token.reduce("") { $0 + String(format: "%02x", $1) }
    self.encoder.outputFormatting = .prettyPrinted
  }

  func encoded() -> Data {
    // swiftlint:disable:next force_try
    return try! encoder.encode(self)
  }
}

extension TokenDetails: Encodable {
  private enum CodingKeys: CodingKey {
    case token, debug
  }
}

extension TokenDetails: CustomStringConvertible {
  var description: String {
    return String(data: encoded(), encoding: .utf8) ?? "Invalid token"
  }
}
