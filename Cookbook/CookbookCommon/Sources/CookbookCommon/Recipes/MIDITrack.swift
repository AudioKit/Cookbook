import AudioKit
import AudioKitUI
import SwiftUI

struct MIDITrackDemo: View {
    public var body: some View {
        ScrollView {
            GeometryReader { geometry in
                MIDITrackView(trackWidth: geometry.size.width - 20,
                              trackHeight: 200.0,
                              fileURL: Bundle.module.url(forResource: "Demo", withExtension: "mid")!,
                              noteZoom: 100_000)
            }
        }
        .padding()
        .navigationBarTitle(Text("MIDI Track View"))
    }
}
