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
            return error.errorDescription
        case .invalidResponse:
            return "Remote venue data returned an invalid response."
        case .nonSuccessStatus(let statusCode):
            return "Remote venue data returned HTTP \(statusCode)."
        case .emptyData:
            return "Remote venue data was empty."
        case .decodingFailure:
            return "Unable to decode remote venue data."
        case .networkFailure(let reason):
            return "Remote venue data request failed: \(reason)"
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
        do {
            return try repository.loadVenues()
        } catch let error as LocalVenueRepositoryError {
            throw VenueDataSourceError.local(error)
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
