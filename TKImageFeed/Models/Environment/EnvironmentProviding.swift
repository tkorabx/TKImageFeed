import Foundation

// 💡 Using a dummy environment setup implementation to simplify things
// There are various tools and solutions to handle it in more elegant way e.g. Inject.
// ⚠️ I chose faster approach as it's a challenge task.
protocol EnvironmentProviding {
    var pexelsFirstPageUrl: URL? { get }
    var photosPageProviding: PhotosPageProviding { get }
    var photoDataProviding: PhotoDataProviding { get }
}
