//
//  TKImageFeedApp.swift
//  TKImageFeed
//
//  Created by Tomasz Korab on 13/04/2024.
//

import SwiftUI

@main
struct TKImageFeedApp: App {
    let environment = ConnectedEnvironment()

    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: FeedViewModel(
                nextPageUrl: environment.pexelsFirstPageUrl,
                photosPageProviding: environment.photosPageProviding,
                photoDataProviding: environment.photoDataProviding
            ))
        }
    }
}
