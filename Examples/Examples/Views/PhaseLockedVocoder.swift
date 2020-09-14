import AudioKit
import AVFoundation
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

    let engine = AKEngine()
    let phaseLockedVocoder: AKPhaseLockedVocoder
    
    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        phaseLockedVocoder = AKPhaseLockedVocoder(file: file)
        engine.output = phaseLockedVocoder
    }


    func start() {

        do {
            try engine.start()
            phaseLockedVocoder.start()
            phaseLockedVocoder.amplitude = 1
            phaseLockedVocoder.pitchRatio = 1
        } catch let err {
            AKLog(err)
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
