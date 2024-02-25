import AudioKitUI
import SwiftUI

struct AudioFileRecipeView: View {
    var body: some View {
        VStack {
            ForEach(TestAudioURLs.allCases, id: \.self) { testURL in
                Text(testURL.rawValue)
                if let url = testURL.url() {
                    AudioFileWaveform(url: url)
                        .background(Color.black)
                }
            }
        }
        .padding()
        #if os(iOS)
        .navigationBarTitle(Text("Audio Files"))
        #endif
    }
}
