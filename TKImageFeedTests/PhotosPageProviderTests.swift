import XCTest

@testable import TKImageFeed

// ☘️ Possible testability improvements
// 1. Add more tests for logic-based types
// 2. Add snapshot tests to track unwanted UI changes
// 3. Add automation tests to test whole flows

final class PhotosPageProviderTests: XCTestCase {
    private let environment = OfflineEnvironment()
    private let dataResponseProvider = MockDataResponseProvider()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let url = URL(string: "https://google.com")!

    override func setUpWithError() throws {
        dataResponseProvider.result = nil
    }

    func testSuccessfulResponse() async throws {
        let data = try encoder.encode(PhotoPageResponse.mock)
        dataResponseProvider.result = .success(data)

        let provider = PhotosPageProvider(authorizationApiKey: "", dataResponseProviding: dataResponseProvider)
        let result = try await provider.page(for: url)

        XCTAssertEqual(result.photos.count, 2)
        XCTAssertEqual(result.photos[0].id, 1)
        XCTAssertEqual(result.photos[1].id, 2)
        XCTAssertNil(result.nextPage)
    }

    func testCorruptedDataFailingResponse() async {
        dataResponseProvider.result = .success(Data())

        let provider = PhotosPageProvider(authorizationApiKey: "", dataResponseProviding: dataResponseProvider)

        do {
            let result = try await provider.page(for: url)
            XCTFail()
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testOtherFailingResponse() async {
        dataResponseProvider.result = .failure(URLError(.networkConnectionLost))

        let provider = PhotosPageProvider(authorizationApiKey: "", dataResponseProviding: dataResponseProvider)

        do {
            let result = try await provider.page(for: url)
            XCTFail()
        } catch let error as URLError {
            XCTAssertEqual(error, URLError(.networkConnectionLost))
        } catch {
            XCTFail()
        }
    }
}

private class MockDataResponseProvider: DataResponseProviding {
    var result: Result<Data, Error>?

    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        switch result {
        case .success(let value):
            return (value, URLResponse())
        case .failure(let error):
            throw error
        case nil:
            fatalError()
        }
    }
}

private extension PhotoPageResponse {
    static var mock: Self {
        PhotoPageResponse(
            photos: [
                PhotoPageResponse.Photo(
                    id: 1,
                    width: 200,
                    height: 300,
                    photographer: "Photographer 1",
                    src: PhotoPageResponse.Photo.Source(
                        original: URL(string: "https://picsum.photos/seed/picsum/200/300"),
                        medium: URL(string: "https://picsum.photos/seed/picsum/200/300")
                    ),
                    alt: "Lorem Ipsum Is Simply Dummy Text Of The Printing And Typesetting Industry. Lorem Ipsum Has Been The Industry's Standard Dummy Text Ever Since The 1500s, When An Unknown Printer Took A Galley Of Type And Scrambled It To Make A Type Specimen Book."
                ),
                PhotoPageResponse.Photo(
                    id: 2,
                    width: 200,
                    height: 300,
                    photographer: "Photographer 2",
                    src: PhotoPageResponse.Photo.Source(
                        original: URL(string: "https://picsum.photos/id/237/200/300"),
                        medium: URL(string: "https://picsum.photos/id/237/200/300")
                    ),
                    alt: "Lorem Ipsum Is Simply Dummy Text Of The Printing And Typesetting Industry. Lorem Ipsum Has Been The Industry's Standard Dummy Text Ever Since The 1500s, When An Unknown Printer Took A Galley Of Type And Scrambled It To Make A Type Specimen Book."
                )
            ],
            nextPage: nil
        )
    }
}
