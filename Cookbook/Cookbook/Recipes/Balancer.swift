import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class BalancerConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer
    let balancer: Balancer
    let variSpeed: VariSpeed
    let osc = Oscillator()

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

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        osc.play()
        variSpeed = VariSpeed(player)
        let fader = Fader(variSpeed)
        balancer = Balancer(osc, comparator: fader)
        engine.output = balancer
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct BalancerView: View {
    @StateObject var conductor = BalancerConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Rate",
                            parameter: self.$conductor.rate,
                            range: 0.3125...5,
                            units: "Generic")
            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.frequency,
                            range: 220...880).padding()
        }
        .padding()
        .navigationBarTitle(Text("Balancer"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Balancer_Previews: PreviewProvider {
    static var previews: some View {
        BalancerView()
    }
}
