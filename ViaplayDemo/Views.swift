import SwiftUI

enum ViewPhase {
  case loading
  case error(Error)
  case page(ViaplayResponse)
}

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

struct PageView: View {
  let page: ViaplayResponse
  let service: ViaplayService

  var body: some View {
    List {
      Section {
        VStack {
          Text(page.title)
          Text(page.description)
        }
        .padding(.vertical, 8)
      }

      Section("Sections") {
        ForEach(page.links.sections.sorted(by: { $0.sectionSort < $1.sectionSort })) { section in
          NavigationLink {
            SectionDetailView(
              section: section,
              service: service
            )
          } label: {
            VStack {
              Text(section.title)
                .font(.headline)
              Text(section.type.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
      }
    }
  }
}

struct SectionDetailView: View {
  let section: ViaplayResponse.Links.Section
  let service: ViaplayService

  @State
  private var phase: ViewPhase = .loading

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
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
    .padding(.vertical, 4)
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

struct ErrorView: View {
  let error: Error
  let retry: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Text("Error")
      Text(error.localizedDescription)
      Button("Retry", action: retry)
        .buttonStyle(.borderedProminent)
    }
    .padding()
  }
}

#Preview {
  ContentView(fetcher: MockViaplayFetcher())
}
