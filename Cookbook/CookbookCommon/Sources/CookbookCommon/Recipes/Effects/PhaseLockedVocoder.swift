import AudioKit
import AudioKitEX
import AudioKitUI
import Controls
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
            Text("Position: \(conductor.position)")
            Ribbon(position: $conductor.position)
                .cornerRadius(10)
                .frame(height: 50)
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
