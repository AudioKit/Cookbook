import AudioKit
import AudioKitUI
import SoundpipeAudioKit
import SwiftUI

struct DripData {
    var playRate: AUValue = 2.0

    var intensity: AUValue = 10
    var dampingFactor: AUValue = 0.2
    var mainResonantFrequency: AUValue = 450
    var firstResonantFrequency: AUValue = 600
    var secondResonantFrequency: AUValue = 750
}

class DrippingSoundsConductor: ObservableObject {
    let engine = AudioEngine()
    let reverb: Reverb
    let drip: Drip
    var drips: CallbackLoop!
    @Published var data = DripData() {
        didSet {
            drip.intensity = data.intensity
            drip.dampingFactor = data.dampingFactor
            drip.mainResonantFrequency = data.mainResonantFrequency
            drip.firstResonantFrequency = data.firstResonantFrequency
            drip.secondResonantFrequency = data.secondResonantFrequency

            if drips != nil { drips.frequency = Double(data.playRate) }
        }
    }

    init() {
        drip = Drip()
        drip.intensity = 100
        reverb = Reverb(drip)
        engine.output = DryWetMixer(drip, reverb)
    }

    func start() {
        do {
            try engine.start()
            drips = CallbackLoop(frequency: Double(data.playRate)) {
                self.drip.trigger()
            }
            drips.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
        drips.stop()
    }
}

struct DrippingSoundsView: View {
    @StateObject var conductor = DrippingSoundsConductor()

    var body: some View {
        ScrollView {
            ParameterSlider(text: "Play Rate",
                            parameter: self.$conductor.data.playRate,
                            range: 0 ... 4,
                            units: "Hz")
            ParameterSlider(text: "Intensity",
                            parameter: self.$conductor.data.intensity,
                            range: 0 ... 300,
                            units: "Generic")
            ParameterSlider(text: "Damping Factor",
                            parameter: self.$conductor.data.dampingFactor,
                            range: 0 ... 2,
                            units: "Generic")
            ParameterSlider(text: "Main Resonant Frequency",
                            parameter: self.$conductor.data.mainResonantFrequency,
                            range: 0 ... 800,
                            units: "Generic")
            ParameterSlider(text: "1st Resonant Frequency",
                            parameter: self.$conductor.data.firstResonantFrequency,
                            range: 0 ... 800,
                            units: "Generic")
            ParameterSlider(text: "2nd Resonant Frequency",
                            parameter: self.$conductor.data.secondResonantFrequency,
                            range: 0 ... 800,
                            units: "Generic")
        }
        .padding()
        .cookbookNavBarTitle("Dripping Sounds")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
