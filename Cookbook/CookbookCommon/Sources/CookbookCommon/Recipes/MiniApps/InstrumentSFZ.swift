import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic
import DunneAudioKit

class InstrumentSFZConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = Sampler()
    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
    }
    
    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
    }
    
    init() {
        DispatchQueue.main.async {
            // Load SFZ file with Dunne Sampler.
            // This needs to be loaded after a delay the first time
            // to get the correct Settings.sampleRate if it is 48_000.
            if let fileURL = Bundle.main.url(forResource: "Sounds/sqr", withExtension: "SFZ") {
                self.instrument.loadSFZ(url: fileURL)
            } else {
                Log("Could not find file")
            }
            self.instrument.masterVolume = 0.15
        }
        engine.output = instrument
    }
}

struct InstrumentSFZView: View {
    @StateObject var conductor = InstrumentSFZConductor()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        let instrumentParams = conductor.instrument.parameters
        let paramsPerLine = horizontalSizeClass == .compact ? 6 : 8
        let instrumentParamsChunked =  instrumentParams.chunked(into: paramsPerLine)

        GeometryReader { geoProxy in
            VStack {
                let paramRows = ForEach(0..<instrumentParamsChunked.count, id: \.self) { chunkIndex in
                    HStack {
                        ForEach(instrumentParamsChunked[chunkIndex], id: \.self) { param in
                            ParameterRow(param: param)
                        }
                    }.padding(5)
                }
                if horizontalSizeClass == .compact {
                    ScrollView {
                        paramRows
                    }
                } else {
                    paramRows
                }
                CookbookKeyboard(noteOn: conductor.noteOn,
                                 noteOff: conductor.noteOff).frame(height: geoProxy.size.height / 5)
            }
        }
        .cookbookNavBarTitle("Instrument SFZ")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension NodeParameter: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(def.identifier)
    }
}

extension NodeParameter: Equatable {
    public static func == (lhs: NodeParameter, rhs: NodeParameter) -> Bool {
        // NodeParameter wraps AUParameter which should 
        // conform to equtable as they are NSObjects
        return lhs.parameter == rhs.parameter
    }
}
