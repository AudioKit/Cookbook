import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PhaseLockedVocoderConductor: ObservableObject, HasAudioEngine {
    @Published var position: Float = 0.0 {
        didSet {
            phaseLockedVocoder.position = position
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
        phaseLockedVocoder.start()

        engine.output = phaseLockedVocoder
    }
}

struct PhaseLockedVocoderView: View {
    @StateObject var conductor = PhaseLockedVocoderConductor()

    var body: some View {
        VStack {
            ParameterSlider(text: "Position",
                            parameter: $conductor.position,
                            range: 0.0 ... 1.0,
                            units: "Percent")
            NodeOutputView(conductor.phaseLockedVocoder)
        }
        .padding()
        .cookbookNavBarTitle("Phase Locked Vocoder")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
