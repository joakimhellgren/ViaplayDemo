import SwiftUI

struct SectionDetailView: View {
  let section: ViaplayResponse.Links.Section
  let service: ViaplayService

  @State
  private var phase: ViewPhase = .loading

  var body: some View {
    VStack(alignment: .leading) {
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
        Text(page.title)
          .font(.headline)
        Text(page.description)
      }
    }
    .navigationTitle(section.title)
    .task {
      await load()
    }
  }

  private func load() async {
    do {
      let page = try await service.fetchPage(from: section.cleanedURL)
      phase = .page(page)
    } catch {
      phase = .error(error)
    }
  }
}
