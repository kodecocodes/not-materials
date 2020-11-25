// In a production application this would be the class that interacts with
// your server.  Just having the stub methods is all that is necessary to
// show where the server would be called from the rest of the code.

final class Server {
  static let shared = Server()

  private init() {}

  public func acceptInvitation(with id: Int) {}
  public func declineInvitation(with id: Int) {}
  public func commentOnInvitation(with id: Int, comment: String) {}
}

