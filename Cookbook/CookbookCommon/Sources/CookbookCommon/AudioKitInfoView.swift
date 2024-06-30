import SwiftUI

struct AudioKitInfoView: View {
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 20) {
                        Image("audiokit-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 150)
                        Image("audiokit-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 150)
                    }
                    Divider()
                    Text("AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS, and tvOS.\n\nMost of the examples that were inside of AudioKit are now in this application.\n\nIn addition to the resources found here, there are various open-source example projects on GitHub and YouTube created by AudioKit contributors.")
                    Spacer()
                }
                .padding()

            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                    .accessibilityHint("Tap to close this screen.")
                }
            }
        }
    }
}

#Preview {
    AudioKitInfoView()
}
