import AudioKit
import AudioToolbox
import SwiftUI
import Combine

struct FMOscillatorData {
    var isPlaying: Bool = false
    var baseFrequency: AUValue = 440
    var carrierMultiplier: AUValue = 1
    var modulatingMultiplier: AUValue = 1
    var modulationIndex: AUValue = 1
    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 1
}

class FMOscillatorConductor: Conductor, ObservableObject {
    @Published var data = FMOscillatorData() {
        didSet {
            if data.isPlaying {
                oscillator.start()
                oscillator.baseFrequency = data.baseFrequency
                oscillator.carrierMultiplier = data.carrierMultiplier
                oscillator.modulatingMultiplier = data.modulatingMultiplier
                oscillator.modulationIndex = data.modulationIndex
                oscillator.amplitude = data.amplitude
                oscillator.rampDuration = data.rampDuration
            } else {
                oscillator.amplitude = 0.0
            }

        }
    }

    var oscillator = AKFMOscillator()

    override func setup() {
        AKManager.output = oscillator
    }
}

struct PresetButton: View {
    var text: String
    var onTap: ()->Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray)
            Text(text).onTapGesture {
                self.onTap()
            }
        }
    }
}

struct FMOscillatorView: View {
    @ObservedObject var conductor = FMOscillatorConductor()
//    var plotView = PlotView()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            HStack(spacing: 10) {
                PresetButton(text: "Stun Ray") { self.conductor.data.stunRay() }
                PresetButton(text: "Wobble")   { self.conductor.data.wobble() }
                PresetButton(text: "Fog Horn") { self.conductor.data.fogHorn() }
                PresetButton(text: "Buzzer")   { self.conductor.data.buzzer() }
                PresetButton(text: "Spiral")   { self.conductor.data.spiral() }
                PresetButton(text: "Random")   { self.conductor.data.randomize() }
            }.padding()
            ParameterSlider(text: "Base Frequency",
                            parameter: self.$conductor.data.baseFrequency,
                            range: 0...800)
            ParameterSlider(text: "Carrier Multiplier",
                            parameter: self.$conductor.data.carrierMultiplier,
                            range: 0...20)
            ParameterSlider(text: "Modulating Multiplier",
                            parameter: self.$conductor.data.modulatingMultiplier,
                            range: 0...20)
            ParameterSlider(text: "Modulation Index",
                            parameter: self.$conductor.data.modulationIndex,
                            range: 0...100)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0...2)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...10)
//            plotView
        }.navigationBarTitle(Text("FM Oscillator"))
        .padding()
        .onAppear {
            self.conductor.start()
//            self.plotView.attach()
        }
    }
}

extension FMOscillatorData {
    /// Stun Ray Preset
    mutating func stunRay() {
        isPlaying = true
        baseFrequency = 200
        carrierMultiplier = 90
        modulatingMultiplier = 10
        modulationIndex = 25
    }

    /// Fog Horn Preset
    mutating func fogHorn() {
        isPlaying = true
        baseFrequency = 25
        carrierMultiplier = 10
        modulatingMultiplier = 5
        modulationIndex = 10
    }

    /// Buzzer Preset
    mutating func buzzer() {
        isPlaying = true
        baseFrequency = 400
        carrierMultiplier = 28
        modulatingMultiplier = 0.5
        modulationIndex = 100
    }

    /// Spiral Preset
    mutating func spiral() {
        isPlaying = true
        baseFrequency = 5
        carrierMultiplier = 280
        modulatingMultiplier = 0.2
        modulationIndex = 100
    }

    /// Wobble Preset
    mutating func wobble() {
        isPlaying = true
        baseFrequency = 20
        carrierMultiplier = 10
        modulatingMultiplier = 0.9
        modulationIndex = 20
    }

    mutating func randomize() {
        isPlaying = true
        baseFrequency = random(in: 0...800)
        carrierMultiplier = random(in: 0...20)
        modulatingMultiplier = random(in: 0...20)
        modulationIndex = random(in: 0...100)
    }

}


struct FMOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        FMOscillatorView()
    }
}
