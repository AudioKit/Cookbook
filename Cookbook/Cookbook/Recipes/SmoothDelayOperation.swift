import AudioKit
import AVFoundation
import SwiftUI

struct SmoothDelayOperationData {
    var time: AUValue = 0.1
    var feedback: AUValue = 0.7
    var rampDuration: AUValue = 0.1
}

class SmoothDelayOperationConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer
    let effect: OperationEffect

    @Published var data = SmoothDelayOperationData() {
        didSet {
            effect.$parameter1.ramp(to: data.time, duration: data.rampDuration)
            effect.$parameter2.ramp(to: data.feedback, duration: data.rampDuration)
        }
    }

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        effect = OperationEffect(player) { player, parameters in
            let delayedPlayer = player.smoothDelay(
                time: parameters[0],
                feedback: parameters[1],
                samples: 1_024,
                maximumDelayTime: 2.0)
            return mixer(player.toMono(), delayedPlayer)
        }
        effect.parameter1 = 0.1
        effect.parameter2 = 0.7

        engine.output = effect
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct SmoothDelayOperationView: View {
    @ObservedObject var conductor = SmoothDelayOperationConductor()

    var body: some View {
        VStack(spacing: 20) {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Time",
                            parameter: self.$conductor.data.time,
                            range: 0...0.3,
                            units: "Seconds")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0...1,
                            units: "%")
        }
        .padding()
        .navigationBarTitle(Text("Smooth Delay Operation"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct SmoothDelayOperation_Previews: PreviewProvider {
    static var previews: some View {
        SmoothDelayOperationView()
    }
}
