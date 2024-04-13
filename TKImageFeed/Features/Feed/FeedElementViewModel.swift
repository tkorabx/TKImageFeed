import OSLog
import SwiftUI
import UIKit

protocol PhotoDataProviding {
    func photoData(for url: URL) async throws -> Data
}

final class FeedElementViewModel: ObservableObject {
    @MainActor @Published var image: UIImage?
    @MainActor @Published var detailsViewModel: DetailsViewModel?

    var id: Int { photo.id }
    var author: String { photo.photographer }

    private let photo: PhotoPageResponse.Photo
    private let photoDataProviding: PhotoDataProviding
    private var loadPhotoDataTask: Task<Void, Error>?
    private let logger = Logger(subsystem: "FeedElementViewModel", category: "API")

    init(photo: PhotoPageResponse.Photo, photoDataProviding: PhotoDataProviding) {
        self.photo = photo
        self.photoDataProviding = photoDataProviding
    }

    deinit {
        loadPhotoDataTask?.cancel()
    }

    func onAppear() {
        loadPhotoData()
    }

    func onDisappear() {
        loadPhotoDataTask?.cancel()
        logger.debug("\(self.id) Ongoing photo data request cancelled")
    }

    @MainActor
    func onButtonSelected() {
        detailsViewModel = DetailsViewModel(photo: photo, photoDataProviding: photoDataProviding)
    }

    private func loadPhotoData() {
        logger.debug("\(self.id) Loading photo data...")

        loadPhotoDataTask?.cancel()
        loadPhotoDataTask = Task { [weak self] in
            guard let id = self?.id, let logger = self?.logger else {
                throw Errors.deinitialised
            }

            do {
                // ☘️ Possible performance improvement
                // Choose photo source depending on the device screen size
                guard let photoDataProviding = self?.photoDataProviding, let url = self?.photo.src.medium else {
                    throw Errors.deinitialised
                }

                let data = try await photoDataProviding.photoData(for: url)

                try Task.checkCancellation()

                await MainActor.run { [weak self] in
                    self?.image = UIImage(data: data)
                    logger.debug("\(id) Loaded photo data!")
                }
            } catch {
                // ☘️ Possible UX improvement
                // Handle failure and indicate it on the user's screen
                // ⚠️ I chose faster approach as it's a challenge task and ignored failures.
                logger.critical("\(id) Failed loading photo data: \(error.localizedDescription)")
            }
        }
    }
}
