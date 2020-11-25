import Foundation

extension String {
  func toInt(minimum: Int = 0, maximum: Int? = nil) -> Int? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmed.isEmpty, let ret = Int(trimmed), ret >= minimum else {
      return nil
    }
    
    if let maximum = maximum, ret > maximum {
      return nil
    }
    
    return ret
  }
}
