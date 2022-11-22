import SwiftUI
import Combine

final class TicketOffice: NSObject, ObservableObject {
  static let shared = TicketOffice()
  private static let purchasedKey = "purchased"

  @Published var purchased: [Movie] = [] {
    didSet {
      let ids = purchased.map { $0.id }
      UserDefaults.standard.setValue(ids, forKey: Self.purchasedKey)
    }
  }

  private var cancellable: Set<AnyCancellable> = []

  let ticketCost = 8.5.formatted(.currency(code: "usd"))

  var movies: [Movie]

  override private init() {
    let decoder = JSONDecoder()

    guard
      let plist = Bundle.main.url(forResource: "movies", withExtension: "json"),
      let data = try? Data(contentsOf: plist),
      let movies = try? decoder.decode([Movie].self, from: data) else {
      fatalError("Where's the movies.json file?")
    }

    self.movies = movies

    let alreadyPurchasedIds = UserDefaults.standard.array(forKey: Self.purchasedKey) as? [Int] ?? []

    purchased = movies.filter { alreadyPurchasedIds.contains($0.id) }

    super.init()

      // 1
    Connectivity.shared.$purchasedIds
      // 2
      .dropFirst()
      // 3
      .map { ids in
        movies.filter { ids.contains($0.id) }
      }
      // 4
      .receive(on: DispatchQueue.main)
      // 5
      .assign(to: \.purchased, on: self)
      //6
      .store(in: &cancellable)

  }

  static func purchasedListPreview() -> TicketOffice {
    let office = TicketOffice()
    office.purchase(office.movies[0])

    return office
  }

  func isPurchased(_ movie: Movie) -> Bool {
    return purchased.contains(movie)
  }

  func purchase(_ movie: Movie) {
    guard !isPurchased(movie) else {
      return
    }

    purchased.append(movie)

    updateCompanion()
  }

  func purchasableMovies() -> [String: [Movie]] {
    let notPurchased = movies.filter { !isPurchased($0) }
    return Dictionary(grouping: notPurchased, by: \.time)
  }

  func delete(at offsets: IndexSet) {
    purchased.remove(atOffsets: offsets)

    updateCompanion()
  }

  private func updateCompanion() {
      // 1
    let ids = purchased.map { $0.id }

      // 2
    Connectivity.shared
      .send(movieIds: ids, delivery: .highPriority, errorHandler: {
        print($0.localizedDescription)
      })
  }
}


