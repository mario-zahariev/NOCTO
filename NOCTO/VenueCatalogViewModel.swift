import Combine
import Foundation
import NOCTOCore

enum VenueCatalogLoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded(count: Int)
    case failed(message: String)
}

@MainActor
final class VenueCatalogViewModel: ObservableObject {
    @Published private(set) var venues: [Venue]
    @Published private(set) var isLoading: Bool
    @Published private(set) var errorMessage: String?
    @Published private(set) var loadState: VenueCatalogLoadState

    private let repository: any VenueRepositoryProviding

    init(venues: [Venue] = []) {
        repository = VenueRepository()
        self.venues = venues
        isLoading = false
        errorMessage = nil
        loadState = Self.initialLoadState(for: venues)
    }

    init(
        repository: any VenueRepositoryProviding,
        venues: [Venue] = []
    ) {
        self.repository = repository
        self.venues = venues
        isLoading = false
        errorMessage = nil
        loadState = Self.initialLoadState(for: venues)
    }

    func fetchCatalog() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        loadState = .loading

        let result = await repository.loadVenues()

        isLoading = false

        switch result {
        case .success(let venues):
            self.venues = venues
            errorMessage = nil
            loadState = .loaded(count: venues.count)
        case .failure(let error):
            let message = Self.userMessage(for: error)
            errorMessage = message
            loadState = .failed(message: message)
        }
    }

    func refresh() async {
        await fetchCatalog()
    }

    private static func userMessage(for error: VenueError) -> String {
        switch error {
        case .notFound:
            return "Не открихме заведенията. Опитай отново."
        case .validationFailed:
            return "Данните за заведенията не минаха проверка."
        case .underlying:
            return "Възникна проблем при зареждането на заведенията."
        case .offline:
            return "Няма достъп до данните за заведенията в офлайн режим."
        }
    }

    private static func initialLoadState(for venues: [Venue]) -> VenueCatalogLoadState {
        venues.isEmpty ? .idle : .loaded(count: venues.count)
    }
}
