import SwiftUI

// ☘️ Possible improvement
// Add calculated height presentation detent to make sheet ideal height for the images not filling the screen height

struct DetailsView: View {
    @StateObject var viewModel: DetailsViewModel

    @State private var animatedImage: UIImage?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack {
                    Color.gray.opacity(0.3)
                        .aspectRatio(viewModel.imageRatio, contentMode: .fit)
                    if let animatedImage {
                        Image(uiImage: animatedImage)
                            .resizable()
                            .scaledToFit()
                            .transition(.opacity)
                    }
                }

                Text(viewModel.description)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(24)

                Text("TAKEN BY")
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.horizontal)

                Text(viewModel.author.uppercased())
                    .font(.headline)
                    .kerning(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .onChange(of: viewModel.image) { _, newValue in
            withAnimation {
                animatedImage = newValue
            }
        }
    }
}

#Preview {
    let environment = OfflineEnvironment()
    let photo = PhotoPageResponse.Photo(
        id: 1,
        width: 200,
        height: 300,
        photographer: "Photographer 1",
        src: PhotoPageResponse.Photo.Source(
            original: URL(string: "https://picsum.photos/seed/picsum/200/300"),
            medium: URL(string: "https://picsum.photos/seed/picsum/200/300")
        ),
        alt: "Lorem Ipsum Is Simply Dummy Text Of The Printing And Typesetting Industry. Lorem Ipsum Has Been The Industry's Standard Dummy Text Ever Since The 1500s, When An Unknown Printer Took A Galley Of Type And Scrambled It To Make A Type Specimen Book."
    )
    let vm = DetailsViewModel(photo: photo, photoDataProviding: environment.photoDataProviding)
    return Color.yellow
        .sheet(item: .constant(vm)) { vm in
            DetailsView(viewModel: vm)
        }
        .ignoresSafeArea()
}
