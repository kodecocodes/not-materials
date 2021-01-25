import Fluent
import Vapor

final class Token: Model {
  static let schema = "tokens"

  @ID(key: .id)
  var id: UUID?
  @Field(key: "token")
  var token: String
  @Field(key: "debug")
  var debug: Bool

  init() { }
  
  init(token: String, debug: Bool) {
    self.token = token
    self.debug = debug
  }
}
