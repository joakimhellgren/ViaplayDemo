import SwiftUI

@main
struct ViaplayDemoApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(fetcher: ViaplayFetcher())
    }
  }
}
