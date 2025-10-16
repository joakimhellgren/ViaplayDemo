import Foundation

protocol APIFetcher {
  func fetch(_ urlString: String) async throws -> ViaplayResponse
}

actor ViaplayFetcher: @MainActor APIFetcher {
  private let cache: ViaplayCache

  init() {
    cache = .init()
  }

  @MainActor
  func fetch(_ urlString: String) async throws -> ViaplayResponse {
    if let cached = cache[urlString] {
      return cached
    }

    guard let url  = URL(string: urlString) else {
      throw ViaplayError.invalidURL
    }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let response = try JSONDecoder().decode(ViaplayResponse.self, from: data)
      cache.cacheResponse(response, for: urlString, data: data)
      return response
    } catch {
      // Try to load from disk cache (offline mode)
      guard let cachedResponse = cache.loadFromDiskCache(urlString) else {
        throw error
      }

      return cachedResponse
    }
  }
}

actor MockViaplayFetcher: @MainActor APIFetcher {
  func fetch(_ urlString: String) async throws -> ViaplayResponse {
    try? await Task.sleep(for: .seconds(.random(in: 0.2...2)))
    return .init(
      type: "root",
      pageType: "pageType",
      title: "Mock Title",
      description: "Mock description",
      links: .init(sections: [
        .init(
          id: "0",
          title: "0",
          href: "123",
          type: "123",
          sectionSort: 0,
          name: "Mock name 0"
        ),
      .init(
        id: "1",
        title: "1",
        href: "234",
        type: "234",
        sectionSort: 1,
        name: "Mock name 1"
      ),
      .init(
        id: "2",
        title: "3",
        href: "345",
        type: "345",
        sectionSort: 2,
        name: "Mock name 2"
      )
    ]))
  }
}
