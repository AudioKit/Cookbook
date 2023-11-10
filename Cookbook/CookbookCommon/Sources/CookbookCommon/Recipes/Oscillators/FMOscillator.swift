import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Combine
import SoundpipeAudioKit
import SwiftUI

class FMOscillatorConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var osc = FMOscillator()

    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? osc.start() : osc.stop() }
    }

    init() {
        engine.output = osc
    }
}

struct PresetButton: View {
    var text: String
    var onTap: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray)
            Text(text).onTapGesture {
                onTap()
            }
        }
    }
}

struct FMOscillatorView: View {
    @StateObject var conductor = FMOscillatorConductor()

    var body: some View {
        VStack {
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isPlaying.toggle()
            }
            HStack(spacing: 10) {
                PresetButton(text: "Stun Ray") { conductor.stunRay() }
                PresetButton(text: "Wobble") { conductor.wobble() }
                PresetButton(text: "Fog Horn") { conductor.fogHorn() }
                PresetButton(text: "Buzzer") { conductor.buzzer() }
                PresetButton(text: "Spiral") { conductor.spiral() }
                PresetButton(text: "Random") { conductor.randomize() }
            }.padding()
            HStack {
                ForEach(conductor.osc.parameters) {
                    ParameterRow(param: $0)
                }
            }
            NodeOutputView(conductor.osc)
        }.cookbookNavBarTitle("FM Oscillator")
            .padding()
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}

extension FMOscillatorConductor {
    /// Stun Ray Preset
    func stunRay() {
        isPlaying = true
        osc.baseFrequency = 200
        osc.carrierMultiplier = 90
        osc.modulatingMultiplier = 10
        osc.modulationIndex = 25
    }

    /// Fog Horn Preset
    func fogHorn() {
        isPlaying = true
        osc.baseFrequency = 25
        osc.carrierMultiplier = 10
        osc.modulatingMultiplier = 5
        osc.modulationIndex = 10
    }

    /// Buzzer Preset
    func buzzer() {
        isPlaying = true
        osc.baseFrequency = 400
        osc.carrierMultiplier = 28
        osc.modulatingMultiplier = 0.5
        osc.modulationIndex = 100
    }

    /// Spiral Preset
    func spiral() {
        isPlaying = true
        osc.baseFrequency = 5
        osc.carrierMultiplier = 280
        osc.modulatingMultiplier = 0.2
        osc.modulationIndex = 100
    }

    /// Wobble Preset
    func wobble() {
        isPlaying = true
        osc.baseFrequency = 20
        osc.carrierMultiplier = 10
        osc.modulatingMultiplier = 0.9
        osc.modulationIndex = 20
    }

    func randomize() {
        isPlaying = true
        osc.baseFrequency = AUValue.random(in: 0 ... 800)
        osc.carrierMultiplier = AUValue.random(in: 0 ... 20)
        osc.modulatingMultiplier = AUValue.random(in: 0 ... 20)
        osc.modulationIndex = AUValue.random(in: 0 ... 100)
    }
}
