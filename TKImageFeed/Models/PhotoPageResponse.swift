import Foundation

// ☘️ Possible readability improvement
// Make properties name more descriptive and use custom coding kets e.g. 'alt' could be 'description'
// ⚠️ I chose faster approach as it's a challenge task.
struct PhotoPageResponse: Codable {
    struct Photo: Codable {
        struct Source: Codable {
            // ☘️ Possible performance improvement
            // Decode all possible sources to allow choosing the ideal image size
            // ⚠️ I chose faster approach as it's a challenge task.
            let original, medium: URL?
        }

        let id: Int
        let width: CGFloat
        let height: CGFloat
        let photographer: String
        let src: Source
        let alt: String
    }

    let photos: [Photo]
    let nextPage: URL?
}
