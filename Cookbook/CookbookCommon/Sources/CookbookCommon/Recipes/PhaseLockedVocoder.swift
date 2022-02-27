import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct PhaseLockedVocoderData {
    var position: Float = 0.0
}

class PhaseLockedVocoderConductor: ObservableObject {
    @Published var data = PhaseLockedVocoderData() {
        didSet {
           phaseLockedVocoder.position = data.position
        }
    }

    let engine = AudioEngine()
    var phaseLockedVocoder: PhaseLockedVocoder

    init() {
        let url = Bundle.module.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        phaseLockedVocoder = PhaseLockedVocoder(file: file)
        phaseLockedVocoder.amplitude = 1
        phaseLockedVocoder.pitchRatio = 1

        engine.output = phaseLockedVocoder
    }

    func start() {

        do {
            try engine.start()
            phaseLockedVocoder.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct PhaseLockedVocoderView: View {
    @StateObject var conductor = PhaseLockedVocoderConductor()

    var body: some View {
        VStack {
            ParameterSlider(text: "Position",
                            parameter: self.$conductor.data.position,
                            range: 0.0...1.0,
                            units: "Percent")
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text("Phase Locked Vocoder"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
