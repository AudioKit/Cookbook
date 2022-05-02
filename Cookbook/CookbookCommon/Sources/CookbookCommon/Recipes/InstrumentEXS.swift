import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class InstrumentEXSConductor: ObservableObject, KeyboardDelegate {

    let engine = AudioEngine()
    private var instrument = MIDISampler(name: "Instrument 1")

    func noteOn(note: MIDINoteNumber) {
        instrument.play(noteNumber: note, velocity: 90, channel: 0)
    }

    func noteOff(note: MIDINoteNumber) {
        instrument.stop(noteNumber: note, channel: 0)
    }

    init() {
        engine.output = instrument
    }

    func start() {
        // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
        do {
            if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sawPiano1", withExtension: "exs") {
                try instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }

    func stop() {
        engine.stop()
    }
}

struct InstrumentEXSView: View {
    @StateObject var conductor = InstrumentEXSConductor()

    var body: some View {
        KeyboardControl(firstOctave: 2,
                        octaveCount: 2,
                        polyphonicMode: true,
                        delegate: conductor)
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct InstrumentEXSView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentEXSView()
    }
}
