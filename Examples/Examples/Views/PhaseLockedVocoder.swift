import AudioKit
import AVFoundation
import SwiftUI

struct PhaseLockedVocoderData {
    var position: Float = 0.0
}

class PhaseLockedVocoderConductor: ObservableObject {
    @Published var data = PhaseLockedVocoderData() {
        didSet {
//            phaseLockedVocoder.position = data.position
            for i in 0..<5 {
                phaseLockedVocoders[i].position = data.position
            }
        }
    }

    let engine = AudioEngine()
    var phaseLockedVocoders: [PhaseLockedVocoder] = []

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        for _ in 0..<5 {
            let vocoder = PhaseLockedVocoder(file: file)
            vocoder.amplitude = 1
            vocoder.pitchRatio = 1
            phaseLockedVocoders.append(vocoder)
        }

        let mixer = Mixer(phaseLockedVocoders[0],
                            phaseLockedVocoders[1],
                            phaseLockedVocoders[2],
                            phaseLockedVocoders[3],
                            phaseLockedVocoders[4])
        engine.output = mixer
    }

    func start() {

        do {
            try engine.start()
            for i in 0..<5 {
                phaseLockedVocoders[i].start()
            }
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct PhaseLockedVocoderView: View {
    @ObservedObject var conductor = PhaseLockedVocoderConductor()

    var body: some View {
        VStack {
            ParameterSlider(text: "Wah",
                            parameter: self.$conductor.data.position,
                            range: 0.0...1.0,
                            units: "Percent")
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
