import AudioKit
import AudioKitUI
import AudioToolbox
import SporthAudioKit
import SwiftUI

class VocalTractOperationConductor: ObservableObject {

    @Published var isPlaying = true {
        didSet {
            isPlaying ? generator.start() : generator.stop()
        }
    }

    let engine = AudioEngine()

    let generator = OperationGenerator {
        let frequency = Operation.sineWave(frequency: 1).scale(minimum: 100, maximum: 300)
        let jitter = Operation.jitter(amplitude: 300, minimumFrequency: 1, maximumFrequency: 3)
        let position = Operation.sineWave(frequency: 0.1).scale()
        let diameter = Operation.sineWave(frequency: 0.2).scale()
        let tenseness = Operation.sineWave(frequency: 0.3).scale()
        let nasality = Operation.sineWave(frequency: 0.35).scale()
        return Operation.vocalTract(frequency: frequency + jitter,
                                    tonguePosition: position,
                                    tongueDiameter: diameter,
                                    tenseness: tenseness,
                                    nasality: nasality)
    }

    init() {
        engine.output = generator
    }

    func start() {
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
        generator.start()
    }

    func stop() {
        generator.stop()
        engine.stop()
    }
}

struct VocalTractOperationView: View {
    @StateObject var conductor = VocalTractOperationConductor()

    var body: some View {
        Text(conductor.isPlaying ? "Stop!" : "More!").onTapGesture {
            self.conductor.isPlaying.toggle()
        }
        .navigationBarTitle(Text("Vocal Fun"))
        .padding()
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct VocalTractOperationView_Previews: PreviewProvider {
    static var previews: some View {
        VocalTractView()
    }
}
