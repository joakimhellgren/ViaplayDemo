import Foundation

@MainActor
class ViaplayService {
  private let fetcher: APIFetcher

  // API Configuration
  private let baseURL = "https://content.viaplay.com/ios-se"

  init(fetcher: APIFetcher) {
    self.fetcher = fetcher
  }

  // Fetch root page from API
  @discardableResult
  func fetchRootPage() async throws -> ViaplayResponse {
    try await fetchPage(from: baseURL)
  }

  // Fetch data with offline support
  @discardableResult
  func fetchPage(from urlString: String) async throws -> ViaplayResponse {
    let response = try await fetcher.fetch(urlString)
    return response
  }
}
