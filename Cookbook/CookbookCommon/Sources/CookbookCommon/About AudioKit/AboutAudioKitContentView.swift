import SwiftUI

struct AboutAudioKitContentView: View {
    private let maxWidth: CGFloat = 200
    var stackSpacing: CGFloat

    var body: some View {
        audioKitArtwork
        audioKitText
    }

    private var audioKitArtwork: some View {
        return VStack(spacing: stackSpacing) {
            Image("audiokit-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: maxWidth)
            Image("audiokit-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: maxWidth)
        }
    }

    private var audioKitText: some View {
        Text("AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS, and tvOS.\n\nMost of the examples that were inside of AudioKit are now in this application.\n\nIn addition to the resources found here, there are various open-source example projects on GitHub and YouTube created by AudioKit contributors.")
            .padding()
    }
}

#Preview {
    AboutAudioKitContentView(stackSpacing: 25)
}
