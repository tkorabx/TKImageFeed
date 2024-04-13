import SwiftUI

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(viewModel.photoViewModels, id: \.id) { viewModel in
                    FeedElementView(viewModel: viewModel)
                }

                if !viewModel.didLoadEverything {
                    FeedProgressView()
                        .onAppear(perform: viewModel.onLoaderAppear)
                }
            }
        }
    }
}

private struct FeedElementView: View {
    @StateObject var viewModel: FeedElementViewModel

    @State private var animatedImage: UIImage?
    
    var body: some View {
        Button {
            viewModel.onButtonSelected()
        } label: {
            content
                .frame(height: 350)
                .overlay {
                    ZStack(alignment: .bottom) {
                        Color.black.opacity(0.5)
                        VStack {
                            Text("TAKEN BY")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(viewModel.author.uppercased())
                                .font(.headline)
                                .kerning(3)
                                .foregroundStyle(.white)
                        }
                        .padding(.bottom, 16)
                    }
                }
                .background(Color.white)
        }
        .buttonStyle(FeedElementButtonStyle())
        .padding(24)
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .sheet(item: $viewModel.detailsViewModel) { vm in
            DetailsView(viewModel: vm)
        }
        .onChange(of: viewModel.image) { _, newValue in
            withAnimation {
                animatedImage = newValue
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        Color.gray.opacity(0.1)
            .overlay {
                if let animatedImage {
                    Image(uiImage: animatedImage)
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                }
            }
    }
}

private struct FeedProgressView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}

private struct FeedElementButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: configuration.isPressed ? Color.clear : Color.gray, radius: 15, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring, value: configuration.isPressed)
    }
}

#Preview {
    let environment = OfflineEnvironment()
    return FeedView(viewModel: FeedViewModel(
        nextPageUrl: environment.pexelsFirstPageUrl,
        photosPageProviding: environment.photosPageProviding,
        photoDataProviding: environment.photoDataProviding
    ))
}
