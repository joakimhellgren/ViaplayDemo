import SwiftUI

struct ErrorView: View {
  let error: Error
  let retry: () -> Void

  var body: some View {
    VStack {
      Text("Error")
      Text(error.localizedDescription)
      Button("Retry", action: retry)
        .buttonStyle(.borderedProminent)
    }
  }
}
