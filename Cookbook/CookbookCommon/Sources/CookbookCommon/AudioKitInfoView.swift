import SwiftUI

struct AudioKitInfoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let stackSpacing: CGFloat = 25
    var body: some View {
        NavigationStack {
            ScrollView {
                if verticalSizeClass == .regular {
                    VStack(spacing: stackSpacing) {
                        AboutAudioKitContentView(stackSpacing: stackSpacing)
                    }
                } else {
                    HStack(spacing: stackSpacing) { AboutAudioKitContentView(stackSpacing: stackSpacing)
                    }
                }
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
