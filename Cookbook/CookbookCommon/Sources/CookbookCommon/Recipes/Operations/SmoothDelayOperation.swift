import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SporthAudioKit
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
                samples: 1024,
                maximumDelayTime: 2.0
            )
            return mixer(player.toMono(), delayedPlayer)
        }
        effect.parameter1 = 0.1
        effect.parameter2 = 0.7

        engine.output = effect
    }
}

struct SmoothDelayOperationView: View {
    @StateObject var conductor = SmoothDelayOperationConductor()

    var body: some View {
        VStack(spacing: 20) {
            PlayerControls(conductor: conductor)
            HStack {
                CookbookKnob(text: "Time",
                                parameter: $conductor.data.time,
                                range: 0 ... 0.3,
                                units: "Seconds")
                CookbookKnob(text: "Feedback",
                                parameter: $conductor.data.feedback,
                                range: 0 ... 1,
                                units: "%")
            }
            NodeOutputView(conductor.effect)
        }
        .padding()
        .cookbookNavBarTitle("Smooth Delay Operation")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
