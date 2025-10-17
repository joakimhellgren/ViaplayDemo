import SwiftUI

struct PageView: View {
  let page: ViaplayResponse
  let service: ViaplayService

  private var sections: [ViaplayResponse.Links.Section] {
    page.links.sections.sorted {
      $0.sectionSort < $1.sectionSort
    }
  }

  var body: some View {
    List {
      Section {
        VStack(alignment: .leading) {
          Text(page.title)
          Text(page.description)
        }
      }

      Section("Sections") {
        ForEach(sections) { section in
          NavigationLink {
            SectionDetailView(
              section: section,
              service: service
            )
          } label: {
            VStack(alignment: .leading) {
              Text(section.title)
                .font(.headline)
              Text(section.type)
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
      }
    }
  }
}
