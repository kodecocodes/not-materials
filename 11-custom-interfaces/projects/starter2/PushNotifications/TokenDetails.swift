import Foundation

struct TokenDetails {
  private let encoder = JSONEncoder()

  let token: String
  let debug: Bool
  let language: String

  init(token: Data) {
    self.token = token.reduce("") { $0 + String(format: "%02x", $1) }
    language = Locale.preferredLanguages[0]

  #if DEBUG
    encoder.outputFormatting = .prettyPrinted
    debug = true
    print(String(describing: self))
  #else
    debug = false
  #endif
  }

  func encoded() -> Data {
    return try! encoder.encode(self)
  }
}

extension TokenDetails: Encodable {
  private enum CodingKeys: CodingKey {
    case token, debug, language
  }
}

extension TokenDetails: CustomStringConvertible {
  var description: String {
    return String(data: encoded(), encoding: .utf8) ?? "Invalid token"
  }
}
