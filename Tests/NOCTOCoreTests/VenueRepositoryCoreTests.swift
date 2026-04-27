import XCTest
@testable import NOCTOCore

final class VenueRepositoryCoreTests: XCTestCase {
    func testDecodeReturnsValidVenuesOnly() throws {
        let json = """
        [
          {
            "id": "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABC",
            "name": "Bedroom Premium",
            "type": "club",
            "latitude": 42.6977,
            "longitude": 23.3219
          },
          {
            "id": "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABD",
            "name": "",
            "type": "bar",
            "latitude": 0,
            "longitude": 0
          }
        ]
        """.data(using: .utf8)!

        let sut = VenueRepositoryCore()
        let venues = try sut.decode(from: json)

        XCTAssertEqual(venues.count, 1)
        XCTAssertEqual(venues.first?.name, "Bedroom Premium")
    }

    func testDecodeThrowsForInvalidJSON() {
        let json = Data("{bad-json}".utf8)
        let sut = VenueRepositoryCore()

        XCTAssertThrowsError(try sut.decode(from: json)) { error in
            XCTAssertEqual(error as? VenueRepositoryCoreError, .invalidJSON)
        }
    }

    func testDecodeThrowsWhenAllEntriesInvalid() {
        let json = """
        [
          {
            "id": "A8E1F9E4-3C2A-4F3E-9B7D-123456789ABC",
            "name": "",
            "type": "club",
            "latitude": 999,
            "longitude": 999
          }
        ]
        """.data(using: .utf8)!

        let sut = VenueRepositoryCore()

        XCTAssertThrowsError(try sut.decode(from: json)) { error in
            XCTAssertEqual(error as? VenueRepositoryCoreError, .noValidVenues)
        }
    }
}
