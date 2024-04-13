import UIKit
import OSLog

final class DetailsViewModel: ObservableObject, Identifiable {
    @MainActor @Published var image: UIImage?

    var id: Int { photo.id }
    var author: String { photo.photographer }
    var description: String { "\"" + photo.alt + "\"" }
    var imageRatio: CGFloat { photo.width / photo.height }

    private let photo: PhotoPageResponse.Photo
    private let photoDataProviding: PhotoDataProviding
    private var loadPhotoDataTask: Task<Void, Error>?
    private let logger = Logger(subsystem: "DetailsViewModel", category: "API")

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

    private func loadPhotoData() {
        logger.debug("\(self.id) Loading photo data...")

        loadPhotoDataTask?.cancel()
        loadPhotoDataTask = Task { [weak self] in
            guard let id = self?.id, let logger = self?.logger else {
                throw Errors.deinitialised
            }

            do {
                // A small delay for better UI experience when showing up the sheet. It could be adjusted
                try? await Task.sleep(for: .seconds(1))
                
                // ☘️ Possible performance improvement
                // Choose photo source depending on the device screen size
                guard let photoDataProviding = self?.photoDataProviding, let url = self?.photo.src.original else {
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
