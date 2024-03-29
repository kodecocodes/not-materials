/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Fluent
import Vapor
import APNS

struct TokenController {
  func create(req: Request) async throws -> HTTPStatus {
    let token = try req.content.decode(Token.self)
    try await token.create(on: req.db)
    return .created
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let token = req.parameters.get("token") else {
      return .badRequest
    }

    guard
      let row = try await Token.query(on: req.db)
        .filter(\.$token == token)
        .first()
    else {
      return .notFound
    }

    try await row.delete(on: req.db)
    return .noContent
  }

  func notify(req: Request) async throws -> HTTPStatus {
    let tokens = try await Token.query(on: req.db).all()

    guard !tokens.isEmpty else {
      return .noContent
    }

    let alert = APNSwiftAlert(title: "Hello!", body: "How are you today?")

    return try await withCheckedThrowingContinuation { continuation in
      do {
        try tokens.map { token in
          req.apns.send(alert, to: token.token)
            .flatMapError {
              guard
                case let APNSwiftError.ResponseError.badRequest(response) = $0,
                response == .badDeviceToken
              else {
                return req.db.eventLoop.future()
              }
              return token.delete(on: req.db)
            }
        }
        .flatten(on: req.eventLoop)
        .wait()
      } catch {
        continuation.resume(throwing: error)
      }

      continuation.resume(returning: .noContent)
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

