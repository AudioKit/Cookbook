import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SporthAudioKit
import SwiftUI

class VocalTractOperationConductor: ObservableObject, HasAudioEngine {
    @Published var isPlaying = false {
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
}

struct VocalTractOperationView: View {
    @StateObject var conductor = VocalTractOperationConductor()

    var body: some View {
        VStack(spacing: 50) {
            Text(conductor.isPlaying ? "Stop!" : "More!")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isPlaying.toggle()
            }
            NodeOutputView(conductor.generator)
        }
        .cookbookNavBarTitle("Vocal Fun")
        .padding()
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
