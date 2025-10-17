import Foundation

@MainActor
class ViaplayService {
  private let fetcher: APIFetcher
  private let baseURL = "https://content.viaplay.com/ios-se"

  init(fetcher: APIFetcher) {
    self.fetcher = fetcher
  }

  @discardableResult
  func fetchRootPage() async throws -> ViaplayResponse {
    try await fetchPage(from: baseURL)
  }

  @discardableResult
  func fetchPage(from urlString: String) async throws -> ViaplayResponse {
    let response = try await fetcher.fetch(urlString)
    return response
  }
}
