import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Controls
import SoundpipeAudioKit
import SwiftUI

class BalancerConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer
    let balancer: Balancer
    let variSpeed: VariSpeed
    let osc = Oscillator()
    let dryWetMixer: DryWetMixer

    @Published var frequency: AUValue = 440 {
        didSet {
            osc.$frequency.ramp(to: frequency, duration: 0.5)
        }
    }

    @Published var rate: AUValue = 1 {
        didSet {
            variSpeed.rate = rate
        }
    }

    @Published var balance: AUValue = 0.5 {
        didSet {
            dryWetMixer.balance = balance
        }
    }

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        osc.play()
        variSpeed = VariSpeed(player)
        let fader = Fader(variSpeed)
        balancer = Balancer(osc, comparator: fader)
        dryWetMixer = DryWetMixer(fader, balancer)
        engine.output = dryWetMixer
    }
}

struct BalancerView: View {
    @StateObject var conductor = BalancerConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                CookbookKnob(text: "Rate", parameter: $conductor.rate, range: 0.3125 ... 5)
                CookbookKnob(text: "Frequency", parameter: $conductor.frequency, range: 220 ... 880)
                ParameterRow(param: conductor.dryWetMixer.parameters[0])
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.balancer,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Balancer")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
