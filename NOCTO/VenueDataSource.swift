import Foundation
import NOCTOCore

enum VenueDataSourceError: LocalizedError, Equatable {
    case local(LocalVenueRepositoryError)
    case invalidResponse
    case nonSuccessStatus(Int)
    case emptyData
    case decodingFailure
    case networkFailure(String)

    var errorDescription: String? {
        switch self {
        case .local(let error):
            switch error {
            case .missingResource:
                return "Локалният файл venues.json не е намерен."
            case .invalidData:
                return "Локалният venues.json е празен или невалиден."
            case .decodingFailure:
                return "Данните за местата не могат да бъдат прочетени."
            case .noValidVenues:
                return "Не са намерени валидни места след проверка."
            }
        case .invalidResponse:
            return "Отдалеченият източник върна невалиден отговор."
        case .nonSuccessStatus(let statusCode):
            return "Отдалеченият източник върна HTTP \(statusCode)."
        case .emptyData:
            return "Отдалеченият източник върна празни данни."
        case .decodingFailure:
            return "Отдалечените данни за местата не могат да бъдат прочетени."
        case .networkFailure(let reason):
            return "Заявката към отдалечения източник не успя: \(reason)"
        }
    }
}

protocol VenueDataSource {
    func loadVenues() async throws -> [Venue]
}

protocol VenueNetworkClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: VenueNetworkClient {}

struct LocalVenueDataSource: VenueDataSource {
    private let repository: any VenueRepositoryProtocol

    init(repository: any VenueRepositoryProtocol = LocalVenueRepository()) {
        self.repository = repository
    }

    func loadVenues() async throws -> [Venue] {
        let repository = repository
        let task = Task.detached(priority: .userInitiated) {
            do {
                return try repository.loadVenues()
            } catch let error as LocalVenueRepositoryError {
                throw VenueDataSourceError.local(error)
            }
        }

        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }
}

struct RemoteVenueDataSource: VenueDataSource {
    private let url: URL
    private let networkClient: any VenueNetworkClient
    private let decoder: VenueRepositoryCore

    init(
        url: URL,
        networkClient: any VenueNetworkClient = URLSession.shared,
        decoder: VenueRepositoryCore = VenueRepositoryCore()
    ) {
        self.url = url
        self.networkClient = networkClient
        self.decoder = decoder
    }

    func loadVenues() async throws -> [Venue] {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await networkClient.data(from: url)
        } catch let error as CancellationError {
            throw error
        } catch {
            throw VenueDataSourceError.networkFailure(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VenueDataSourceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw VenueDataSourceError.nonSuccessStatus(httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw VenueDataSourceError.emptyData
        }

        do {
            return try decoder.decode(from: data)
        } catch {
            throw VenueDataSourceError.decodingFailure
        }
    }
}
