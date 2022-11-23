import SwiftUI

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  @ObservedObject private var model = ContentModel()

  var body: some View {
    VStack {
      Button {
        model.startBrushing()
      } label: {
        Text("Start brushing")
      }
      .disabled(model.roundsLeft != 0)
      .padding()

      if let endOfBrushing = model.endOfBrushing, let endOfRound = model.endOfRound {
        Text("Rounds Left: \(model.roundsLeft - 1)")
        Text("Total time left: \(endOfBrushing, style: .timer)")
        Text("This round time left: \(endOfRound, style: .timer)")
      }
    }
    .onChange(of: scenePhase) { print($0) }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
