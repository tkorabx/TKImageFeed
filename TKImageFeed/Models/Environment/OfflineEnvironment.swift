import Foundation

// 💡 Using a dummy offline/mock implementation to simplify testing process
// 1. Offline one allows to easily connect previews with fake data
// 2. It reduces number of paid API calls during UI development via previews
// 3. It's a great solution to easily disconnect app and make sure everything always work as expected (recommended for the app demo meetings)
// 4. It could be combined with custom targets to easily switch between connected/offline app.
// 5. Only this environment configuration is shared to tests target
class OfflineEnvironment: EnvironmentProviding {
    let pexelsFirstPageUrl = URL(string: "https://google.com") // Just fake URL to make the flow work
    let photosPageProviding: any PhotosPageProviding = OfflinePhotosPageProvider()
    let photoDataProviding: any PhotoDataProviding = OfflinePhotoDataProvider()
}
