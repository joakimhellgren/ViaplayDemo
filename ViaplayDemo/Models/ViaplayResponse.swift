import Foundation

struct ViaplayResponse: Codable {
  let type: String
  let pageType: String
  let title: String
  let description: String
  let links: Self.Links

  enum CodingKeys: String, CodingKey {
    case type, pageType, title, description
    case links = "_links"
  }

  struct Links: Codable {
    let sections: [Self.Section]

    enum CodingKeys: String, CodingKey {
      case sections = "viaplay:sections"
    }

    struct Section: Codable, Identifiable {
      let id: String
      let title: String
      let href: String
      let type: String
      let sectionSort: Int
      let name: String

      var cleanedURL: String {
        // Remove URI template parameters
        href.components(separatedBy: "{").first ?? href
      }
    }
  }
}
