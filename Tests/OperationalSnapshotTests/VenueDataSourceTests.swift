import Foundation
import XCTest
@testable import NOCTOAppLogic
import NOCTOCore

final class VenueDataSourceTests: XCTestCase {
    private var remoteURL: URL {
        URL(string: "https://example.com/venues.json") ?? URL(fileURLWithPath: "/venues.json")
    }

    func testLocalSourceStillLoadsFromInjectedRepository() async throws {
        let expected = [makeVenue(name: "Local Club")]
        let sut = LocalVenueDataSource(repository: StubLocalRepository(result: .success(expected)))

        let venues = try await sut.loadVenues()

        XCTAssertEqual(venues, expected)
    }

    func testLocalSourceMapsRepositoryError() async {
        let sut = LocalVenueDataSource(repository: StubLocalRepository(result: .failure(.missingResource)))

        await assertVenueDataSourceError(.local(.missingResource)) {
            _ = try await sut.loadVenues()
        }
    }

    @MainActor
    func testLocalSourceLoadsInjectedRepositoryOffMainThread() async throws {
        let repository = ThreadCapturingLocalRepository(result: .success([makeVenue(name: "Background Club")]))
        let sut = LocalVenueDataSource(repository: repository)

        _ = try await sut.loadVenues()

        XCTAssertEqual(repository.didLoadOnMainThread, false)
    }

    func testRepositoryDelegatesToAsyncSource() async throws {
        let source = StubVenueDataSource(result: .success([makeVenue(name: "Delegated Club")]))
        let sut = VenueRepository(dataSource: source)

        let venues = try await sut.loadVenues()

        XCTAssertEqual(source.loadCount, 1)
        XCTAssertEqual(venues.first?.name, "Delegated Club")
    }

    func testRemoteSourceDecodesValidVenueJSON() async throws {
        let networkClient = StubNetworkClient(
            result: .success((validVenueData(name: "Remote Club"), try makeHTTPResponse(statusCode: 200)))
        )
        let sut = RemoteVenueDataSource(url: remoteURL, networkClient: networkClient)

        let venues = try await sut.loadVenues()

        XCTAssertEqual(venues.count, 1)
        XCTAssertEqual(venues.first?.name, "Remote Club")
        XCTAssertEqual(networkClient.requestedURLs, [remoteURL])
    }

    func testRemoteSourceFiltersInvalidVenuesThroughCoreDecoder() async throws {
        let data = Data(
            """
            [
              {
                "id": "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABC",
                "name": "Valid Remote Club",
                "type": "club",
                "latitude": 42.6977,
                "longitude": 23.3219
              },
              {
                "id": "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABD",
                "name": "",
                "type": "bar",
                "latitude": 999,
                "longitude": 999
              }
            ]
            """.utf8
        )
        let sut = RemoteVenueDataSource(
            url: remoteURL,
            networkClient: StubNetworkClient(result: .success((data, try makeHTTPResponse(statusCode: 200))))
        )

        let venues = try await sut.loadVenues()

        XCTAssertEqual(venues.count, 1)
        XCTAssertEqual(venues.first?.name, "Valid Remote Club")
    }

    func testRemoteSourceFailsOnInvalidResponse() async throws {
        let response = URLResponse(url: remoteURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let sut = RemoteVenueDataSource(
            url: remoteURL,
            networkClient: StubNetworkClient(result: .success((validVenueData(), response)))
        )

        await assertVenueDataSourceError(.invalidResponse) {
            _ = try await sut.loadVenues()
        }
    }

    func testRemoteSourceFailsOnNonSuccessStatus() async throws {
        let sut = RemoteVenueDataSource(
            url: remoteURL,
            networkClient: StubNetworkClient(
                result: .success((validVenueData(), try makeHTTPResponse(statusCode: 503)))
            )
        )

        await assertVenueDataSourceError(.nonSuccessStatus(503)) {
            _ = try await sut.loadVenues()
        }
    }

    func testRemoteSourceFailsOnEmptyData() async throws {
        let sut = RemoteVenueDataSource(
            url: remoteURL,
            networkClient: StubNetworkClient(
                result: .success((Data(), try makeHTTPResponse(statusCode: 200)))
            )
        )

        await assertVenueDataSourceError(.emptyData) {
            _ = try await sut.loadVenues()
        }
    }

    func testRemoteSourceFailsOnInvalidData() async throws {
        let sut = RemoteVenueDataSource(
            url: remoteURL,
            networkClient: StubNetworkClient(
                result: .success((Data("{bad-json}".utf8), try makeHTTPResponse(statusCode: 200)))
            )
        )

        await assertVenueDataSourceError(.decodingFailure) {
            _ = try await sut.loadVenues()
        }
    }

    func testRemoteSourceMapsNetworkFailure() async {
        let sut = RemoteVenueDataSource(
            url: remoteURL,
            networkClient: StubNetworkClient(result: .failure(URLError(.notConnectedToInternet)))
        )

        do {
            _ = try await sut.loadVenues()
            XCTFail("Expected network failure.")
        } catch let error as VenueDataSourceError {
            guard case .networkFailure = error else {
                XCTFail("Expected networkFailure, got \(error).")
                return
            }
        } catch {
            XCTFail("Expected VenueDataSourceError, got \(error).")
        }
    }

    func testRemoteSourceRethrowsCancellation() async {
        let sut = RemoteVenueDataSource(
            url: remoteURL,
            networkClient: StubNetworkClient(result: .failure(CancellationError()))
        )

        do {
            _ = try await sut.loadVenues()
            XCTFail("Expected cancellation.")
        } catch is CancellationError {
            return
        } catch {
            XCTFail("Expected CancellationError, got \(error).")
        }
    }

    func testVenueDataSourceErrorDescriptionsAreLocalizedForUserDisplay() {
        XCTAssertEqual(
            VenueDataSourceError.local(.missingResource).errorDescription,
            "Локалният файл venues.json не е намерен."
        )
        XCTAssertEqual(
            VenueDataSourceError.invalidResponse.errorDescription,
            "Отдалеченият източник върна невалиден отговор."
        )
        XCTAssertEqual(
            VenueDataSourceError.nonSuccessStatus(503).errorDescription,
            "Отдалеченият източник върна HTTP 503."
        )
        XCTAssertEqual(
            VenueDataSourceError.emptyData.errorDescription,
            "Отдалеченият източник върна празни данни."
        )
        XCTAssertEqual(
            VenueDataSourceError.decodingFailure.errorDescription,
            "Отдалечените данни за местата не могат да бъдат прочетени."
        )
        XCTAssertEqual(
            VenueDataSourceError.networkFailure("offline").errorDescription,
            "Заявката към отдалечения източник не успя: offline"
        )
    }

    private func assertVenueDataSourceError(
        _ expected: VenueDataSourceError,
        operation: () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expected).", file: file, line: line)
        } catch let error as VenueDataSourceError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Expected VenueDataSourceError, got \(error).", file: file, line: line)
        }
    }

    private func makeHTTPResponse(
        statusCode: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> HTTPURLResponse {
        try XCTUnwrap(
            HTTPURLResponse(url: remoteURL, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil),
            file: file,
            line: line
        )
    }

    private func validVenueData(name: String = "Remote Venue") -> Data {
        Data(
            """
            [
              {
                "id": "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABC",
                "name": "\(name)",
                "type": "club",
                "latitude": 42.6977,
                "longitude": 23.3219
              }
            ]
            """.utf8
        )
    }

    private func makeVenue(name: String) -> Venue {
        let id = UUID(uuidString: "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABC") ?? UUID()
        return Venue(
            id: id,
            name: name,
            type: .club,
            latitude: 42.6977,
            longitude: 23.3219
        )
    }
}

private struct StubLocalRepository: VenueRepositoryProtocol {
    let result: Result<[Venue], LocalVenueRepositoryError>

    func loadVenues() throws -> [Venue] {
        try result.get()
    }
}

private final class ThreadCapturingLocalRepository: VenueRepositoryProtocol {
    private let result: Result<[Venue], LocalVenueRepositoryError>
    private(set) var didLoadOnMainThread: Bool?

    init(result: Result<[Venue], LocalVenueRepositoryError>) {
        self.result = result
    }

    func loadVenues() throws -> [Venue] {
        didLoadOnMainThread = Thread.isMainThread
        return try result.get()
    }
}

private final class StubVenueDataSource: VenueDataSource {
    private let result: Result<[Venue], Error>
    private(set) var loadCount = 0

    init(result: Result<[Venue], Error>) {
        self.result = result
    }

    func loadVenues() async throws -> [Venue] {
        loadCount += 1
        return try result.get()
    }
}

private final class StubNetworkClient: VenueNetworkClient {
    let result: Result<(Data, URLResponse), Error>
    private(set) var requestedURLs: [URL] = []

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestedURLs.append(url)
        return try result.get()
    }
}
