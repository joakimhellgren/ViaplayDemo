import Foundation

enum ViaplayError: LocalizedError {
  case invalidURL
  case networkError
  case decodingError

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .networkError:
      return "Network error occurred"
    case .decodingError:
      return "Failed to decode response"
    }
  }
}


