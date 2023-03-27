import AudioKit
import AudioKitEX
import AudioKitUI
import SwiftUI

struct MIDITrackDemo: View {
    @StateObject var viewModel = MIDITrackViewModel()
    @State var fileURL: URL? = Bundle.module.url(forResource: "MIDI Files/Demo", withExtension: "mid")
    @State var isPlaying = false
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    if let fileURL = fileURL {
                        ForEach(
                            MIDIFile(url: fileURL).tracks.indices, id: \.self
                        ) { number in
                            MIDITrackView(fileURL: $fileURL,
                                          trackNumber: number,
                                          trackWidth: geometry.size.width,
                                          trackHeight: 200.0)
                                .background(Color.primary)
                                .cornerRadius(10.0)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationBarTitle(Text("MIDI Track View"))
        .onTapGesture {
            isPlaying.toggle()
        }
        .onChange(of: isPlaying, perform: { newValue in
            if newValue == true {
                viewModel.play()
            } else {
                viewModel.stop()
            }
        })
        .onAppear(perform: {
            viewModel.startEngine()
            if let fileURL = Bundle.module.url(forResource: "MIDI Files/Demo", withExtension: "mid") {
                viewModel.loadSequencerFile(fileURL: fileURL)
            }
        })
        .onDisappear(perform: {
            viewModel.stop()
            viewModel.stopEngine()
        })
        .environmentObject(viewModel)
    }
}
