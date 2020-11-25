import SwiftUI

public enum MainView {
  case Normal, Beach
}

final class ViewRouter: ObservableObject {
  @Published var displayed = MainView.Normal
}
