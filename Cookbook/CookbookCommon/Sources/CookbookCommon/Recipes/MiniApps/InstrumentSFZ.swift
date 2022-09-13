import AudioKit
import AudioKitUI
import AVFoundation
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic
import DunneAudioKit

class InstrumentSFZConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    private var instrument = Sampler()

    func noteOn(pitch: Pitch, point _: CGPoint) {
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
    }

    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
    }

    init() {
        // Load SFZ file with Dunne Sampler
        if let fileURL = Bundle.main.url(forResource: "Sounds/sqr", withExtension: "SFZ") {
            instrument.loadSFZ(url: fileURL)
        } else {
            Log("Could not find file")
        }
        instrument.masterVolume = 0.2
        
        engine.output = instrument
        
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }
}

struct InstrumentSFZView: View {
    @StateObject var conductor = InstrumentSFZConductor()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        CookbookKeyboard(noteOn: conductor.noteOn,
                         noteOff: conductor.noteOff)
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
