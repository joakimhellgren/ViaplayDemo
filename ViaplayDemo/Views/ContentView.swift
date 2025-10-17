import SwiftUI

struct ContentView: View {
  let service: ViaplayService

  init(fetcher: APIFetcher) {
    self.service = ViaplayService(fetcher: fetcher)
  }

  @State
  private var phase: ViewPhase = .loading

  var body: some View {
    NavigationStack {
      VStack {
        switch phase {
        case .loading:
          ProgressView()
        case .error(let error):
          ErrorView(error: error) {
            Task {
              await load()
            }
          }
        case .page(let page):
          PageView(
            page: page,
            service: service
          )
        }
      }
      .navigationTitle("Viaplay")
      .task {
        await load()
      }
    }
  }

  private func load() async {
    do {
      let page = try await service.fetchRootPage()
      phase = .page(page)
    } catch {
      phase = .error(error)
    }
  }
}


#Preview {
  ContentView(fetcher: MockViaplayFetcher())
}
