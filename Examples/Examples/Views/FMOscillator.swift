import AudioKit
import AudioToolbox
import SwiftUI

class FMOscillatorConductor: Conductor, ObservableObject {
    @Published var refresh = true

    @Published var oscillator = AKFMOscillator()

    @Published var rampDuration: AUValue = 0.002 {
        didSet { oscillator.rampDuration = Double(rampDuration) }
    }

    func randomize() {
        oscillator.baseFrequency = random(in: 0...800)
        oscillator.carrierMultiplier = random(in: 0...20)
        oscillator.modulatingMultiplier = random(in: 0...20)
        oscillator.modulationIndex = random(in: 0...100)
        refresh.toggle()
    }

    override func setup() {
        oscillator.amplitude = 0.1
        oscillator.rampDuration = 0.1
        AKManager.output = oscillator
        refresh.toggle()
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

    var body: some View {
        VStack {
            Text(self.conductor.oscillator.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.oscillator.isPlaying ? self.conductor.oscillator.stop() : self.conductor.oscillator.start()
                self.conductor.refresh.toggle()
            }
            HStack(spacing: 10) {
                PresetButton(text: "Stun Ray") { self.conductor.oscillator.presetStunRay(); self.conductor.refresh.toggle() }
                PresetButton(text: "Wobble")   { self.conductor.oscillator.presetWobble(); self.conductor.refresh.toggle() }
                PresetButton(text: "Fog Horn") { self.conductor.oscillator.presetFogHorn(); self.conductor.refresh.toggle() }
                PresetButton(text: "Buzzer")   { self.conductor.oscillator.presetBuzzer(); self.conductor.refresh.toggle() }
                PresetButton(text: "Spiral")   { self.conductor.oscillator.presetSpiral(); self.conductor.refresh.toggle() }
                PresetButton(text: "Random")   { self.conductor.randomize() }
            }.padding()
            ParameterSlider(text: "Base Frequency",
                            parameter: self.$conductor.oscillator.baseFrequency,
                            range: 0...800)
            ParameterSlider(text: "Carrier Multiplier",
                            parameter: self.$conductor.oscillator.carrierMultiplier,
                            range: 0...20)
            ParameterSlider(text: "Modulating Multiplier",
                            parameter: self.$conductor.oscillator.modulatingMultiplier,
                            range: 0...20)
            ParameterSlider(text: "Modulation Index",
                            parameter: self.$conductor.oscillator.modulationIndex,
                            range: 0...100)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.oscillator.amplitude,
                            range: 0...2)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.rampDuration,
                            range: 0...10)
        }.navigationBarTitle(Text("FM Oscillator"))
        .padding()
        .onAppear {
            self.conductor.start()
        }
    }
}

struct FMOscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        FMOscillatorView()
    }
}
