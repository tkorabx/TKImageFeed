import OSLog

protocol PhotosPageProviding {
    func page(for url: URL) async throws -> PhotoPageResponse
}

final class FeedViewModel: ObservableObject {
    @MainActor @Published var photoViewModels: [FeedElementViewModel] = []
    @MainActor @Published var didLoadEverything = false

    // 💡 Using API-provided URL to track if next pages are available
    // Thus, there is no need for properties like current page etc.
    private var nextPageUrl: URL?
    private let photosPageProviding: PhotosPageProviding
    private let photoDataProviding: PhotoDataProviding
    private var loadPageTask: Task<Void, Error>?
    private let logger = Logger(subsystem: "FeedViewModel", category: "API")

    init(nextPageUrl: URL?, photosPageProviding: PhotosPageProviding, photoDataProviding: PhotoDataProviding) {
        self.nextPageUrl = nextPageUrl
        self.photosPageProviding = photosPageProviding
        self.photoDataProviding = photoDataProviding
    }

    deinit {
        loadPageTask?.cancel()
    }

    func onLoaderAppear() {
        logger.debug("Next page requested")
        loadNextPage()
    }

    private func loadNextPage() {
        guard let nextPageUrl else {
            logger.debug("Next page request rejected. The whole content is already loaded.")
            return
        }

        logger.debug("\(nextPageUrl) Loading page...")

        loadPageTask?.cancel()
        loadPageTask = Task { [weak self] in
            guard let logger = self?.logger else {
                throw Errors.deinitialised
            }

            do {
                guard let photosPageProviding = self?.photosPageProviding else {
                    throw Errors.deinitialised
                }

                let pageResponse = try await photosPageProviding.page(for: nextPageUrl)

                guard let photoDataProviding = self?.photoDataProviding else {
                    throw Errors.deinitialised
                }

                try Task.checkCancellation()

                let newViewModels = pageResponse.photos.map {
                    FeedElementViewModel(
                        photo: $0,
                        photoDataProviding: photoDataProviding
                    )
                }

                await MainActor.run { [weak self] in
                    self?.photoViewModels.append(contentsOf: newViewModels)
                    self?.nextPageUrl = pageResponse.nextPage
                    self?.didLoadEverything = pageResponse.nextPage == nil
                    logger.debug("\(nextPageUrl) Loaded page!")
                }
            } catch {
                // ☘️ Possible UX improvement
                // Handle failure and indicate it on the user's screen
                // ⚠️ I chose faster approach as it's a challenge task and ignored failures.
                logger.critical("\(nextPageUrl) Failed loading page: \(error.localizedDescription)")
            }
        }
    }
}
