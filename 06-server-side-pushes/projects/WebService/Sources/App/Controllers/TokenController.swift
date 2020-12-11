import Fluent
import Vapor
import APNS

struct TokenController {
  func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
    try req.content.decode(Token.self)
      .create(on: req.db)
      .transform(to: .noContent)
  }
  
  func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let token = req.parameters.get("token")!
    return Token.query(on: req.db)
      .filter(\.$token == token)
      .first()
      .unwrap(or: Abort(.notFound))
      .flatMap { $0.delete(on: req.db) }
      .transform(to: .noContent)
  }
  
  func notify(req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let alert = APNSwiftAlert(title: "Hello!", body: "How are you today?")
    
    return Token.query(on: req.db)
      .all()
      .flatMap { tokens in
        tokens.map { token in
          req.apns.send(alert, to: token.token)
            .flatMapError {
              // Unless APNs said it was a bad device token, just ignore the error.
              guard case let APNSwiftError.ResponseError.badRequest(response) = $0,
                response == .badDeviceToken else {
                return req.db.eventLoop.future()
              }

              return token.delete(on: req.db)
            }
        }
        .flatten(on: req.eventLoop)
        .transform(to: .noContent)
      }
  }
}

extension TokenController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let tokens = routes.grouped("token")
    tokens.post(use: create)
    tokens.delete(":token", use: delete)
    tokens.post("notify", use: notify)
  }
}
