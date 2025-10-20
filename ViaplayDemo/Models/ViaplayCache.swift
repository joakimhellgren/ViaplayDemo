import Foundation

actor ViaplayCache {
  // Memory cache
  private let cache = NSCache<NSString, CachedResponse>()

  // Disk cache
  private lazy var cacheDirectory: URL = {
    let docDir = FileManager.default.urls(
      for: .cachesDirectory, in: .userDomainMask
    )[0]

    let cache = docDir.appendingPathComponent("ViaplayCache")

    try? FileManager.default.createDirectory(
      at: cache,
      withIntermediateDirectories: true
    )

    return cache
  }()

  /// Retrieves a (valid) cached response for the specified key
  subscript(_ key: String) -> ViaplayResponse? {
    guard let cachedResponse = cache.object(forKey: key as NSString) else {
      return nil
    }

    // Clear cache if expired.
    if cachedResponse.isExpired {
      clearCache()
      return nil
    }

    return cachedResponse.response
  }

  /// Caches data (memory & disk) retrieved from the API response.
  func cacheResponse(
    _ response: ViaplayResponse,
    for urlString: String,
    data: Data
  ) {
    // Memory cache
    let cached = CachedResponse(response: response, timestamp: Date())
    cache.setObject(cached, forKey: urlString as NSString)

    // Disk cache
    let filename = urlString.addingPercentEncoding(
      withAllowedCharacters: .alphanumerics
    ) ?? UUID().uuidString

    let cacheDir = cacheDirectory
    let fileURL = cacheDir.appendingPathComponent(filename)
    try? data.write(to: fileURL)
  }

  /// Loads any cache data from disk.
  func loadFromDiskCache(_ urlString: String) async -> ViaplayResponse? {
    let filename = urlString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
    let cacheDirectory = self.cacheDirectory

    let response = await Task { @MainActor () -> ViaplayResponse? in
      let fileURL = cacheDirectory.appendingPathComponent(filename)
      
      guard let data = try? Data(contentsOf: fileURL) else {
        return nil
      }

      return try? JSONDecoder().decode(ViaplayResponse.self, from: data)
    }.value

    guard let validResponse = response else {
      return nil
    }

    updateMemoryCache(response: validResponse, for: urlString)

    return validResponse
  }

  /// Helper to update memory cache (actor-isolated)
  private func updateMemoryCache(response: ViaplayResponse, for urlString: String) {
    let cached = CachedResponse(response: response, timestamp: Date())
    cache.setObject(cached, forKey: urlString as NSString)
  }

  /// Remove all cached data.
  private func clearCache() {
    cache.removeAllObjects()
    let fileManager = FileManager.default
    let cacheDir = cacheDirectory
    try? fileManager.removeItem(at: cacheDir)
    try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
  }
}

fileprivate extension ViaplayCache {
  class CachedResponse {
    let response: ViaplayResponse
    private let timestamp: Date

    // Expires after 15 minutes.
    var isExpired: Bool {
      let expirationTime: TimeInterval = 15 * 60
      let now = Date()
      return now.timeIntervalSince(timestamp) > expirationTime
    }

    init(response: ViaplayResponse, timestamp: Date) {
      self.response = response
      self.timestamp = timestamp
    }
  }
}
