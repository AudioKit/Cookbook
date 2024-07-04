// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKitUI/

import PianoRoll
import SwiftUI

public struct PianoRollView: View {
    public init() {}

    @State var model = PianoRollModel(notes: [
        PianoRollNote(start: 1, length: 2, pitch: 3),
        PianoRollNote(start: 5, length: 1, pitch: 4),
    ], length: 128, height: 128)

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Tap inside of the scrolling grid to set a note.")
                .padding([.top, .horizontal])
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                PianoRoll(model: $model, noteColor: .cyan, gridColor: .primary, layout: .horizontal)
            }
            .padding()
        }
        .foregroundStyle(.primary)
        .navigationTitle("Piano Roll Demo")
    }
}
