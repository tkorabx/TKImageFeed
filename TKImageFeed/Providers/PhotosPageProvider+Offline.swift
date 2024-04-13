import Foundation

protocol DataResponseProviding {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

final class PhotosPageProvider: PhotosPageProviding {
    private let dataResponseProviding: DataResponseProviding
    private let authorizationApiKey: String
    private let decoder: JSONDecoder

    init(authorizationApiKey: String, dataResponseProviding: DataResponseProviding) {
        self.authorizationApiKey = authorizationApiKey
        self.dataResponseProviding = dataResponseProviding
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func page(for url: URL) async throws -> PhotoPageResponse {
        var request = URLRequest(url: url)
        request.addValue(authorizationApiKey, forHTTPHeaderField: .authorizationHeader)
        let (data, _) = try await dataResponseProviding.data(for: request, delegate: nil)
        return try decoder.decode(PhotoPageResponse.self, from: data)
    }
}

final class OfflinePhotosPageProvider: PhotosPageProviding {
    func page(for url: URL) async throws -> PhotoPageResponse {
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

private extension String {
    static var authorizationHeader: String { "Authorization"}
}
