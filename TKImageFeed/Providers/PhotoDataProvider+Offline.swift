import Foundation

final class PhotoDataProvider: PhotoDataProviding {
    func photoData(for url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

final class OfflinePhotoDataProvider: PhotoDataProviding {
    func photoData(for url: URL) async throws -> Data {
        try await URLSession.shared.data(from: url).0
    }
}
