import Foundation

// ☘️ Possible security improvement
// Inject sensitive data here using approaches like .plist, .xcconfig, CocoaPods Keys or third-party providers
// ⚠️ I chose faster approach as it's a challenge task.
class ConnectedEnvironment: EnvironmentProviding {
    // ☘️ Possible security improvement
    // Build request on your own rather than injected already working one. This would prevent exposing this string in binary.
    // ⚠️ I chose faster approach as it's a challenge task.
    let pexelsFirstPageUrl = URL(string: "https://api.pexels.com/v1/curated?per_page=10&page=1")
    #warning("Provide your own API key")
    let photosPageProviding: any PhotosPageProviding = PhotosPageProvider(authorizationApiKey: "", dataResponseProviding: URLSession.shared)
    let photoDataProviding: any PhotoDataProviding = PhotoDataProvider()
}
