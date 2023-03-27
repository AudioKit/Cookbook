import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

class PluckedStringConductor: ObservableObject {
    let engine = AudioEngine()
    let pluckedString = PluckedString()
    let pluckedString2 = PluckedString()
    var reverb: Reverb
    var playRate = 3.0
    var loop: CallbackLoop!

    @Published var isRunning = false {
        didSet {
            isRunning ? loop.start() : loop.stop()
        }
    }

    init() {
        let mixer = DryWetMixer(pluckedString, pluckedString2)
        let delay = Delay(mixer)
        delay.time = AUValue(1.5 / playRate)
        delay.dryWetMix = 0.7
        delay.feedback = 0.9
        reverb = Reverb(delay)
        reverb.dryWetMix = 0.9
        engine.output = reverb
    }

    func start() {
        do {
            try engine.start()
            loop = CallbackLoop(frequency: playRate) {
                let scale = [60, 62, 65, 66, 67, 69, 71]
                let note1 = Int(AUValue.random(in: 0.0 ..< Float(scale.count)))
                let note2 = Int(AUValue.random(in: 0.0 ..< Float(scale.count)))
                let newAmp = AUValue.random(in: 0.0 ... 1.0)
                self.pluckedString.frequency = scale[note1].midiNoteToFrequency()
                self.pluckedString.amplitude = newAmp
                self.pluckedString2.frequency = scale[note2].midiNoteToFrequency()
                self.pluckedString2.amplitude = newAmp
                if AUValue.random(in: 0.0 ... 30.0) > 15 {
                    self.pluckedString.trigger()
                    self.pluckedString2.trigger()
                }
            }
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
        loop.stop()
    }
}

struct PluckedStringView: View {
    @ObservedObject var conductor = PluckedStringConductor()

    var body: some View {
        VStack {
            Text(conductor.isRunning ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isRunning.toggle()
            }
            NodeOutputView(conductor.reverb)
        }
        .padding()
        .cookbookNavBarTitle("Plucked String")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
