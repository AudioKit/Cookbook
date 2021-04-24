import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct TanhDistortionData {
    var pregain: AUValue = 2.0
    var postgain: AUValue = 0.5
    var positiveShapeParameter: AUValue = 0.0
    var negativeShapeParameter: AUValue = 0.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class TanhDistortionConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let distortion: TanhDistortion
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        distortion = TanhDistortion(player)
        dryWetMixer = DryWetMixer(player, distortion)
        engine.output = dryWetMixer
    }

    @Published var data = TanhDistortionData() {
        didSet {
            distortion.$pregain.ramp(to: data.pregain, duration: data.rampDuration)
            distortion.$postgain.ramp(to: data.postgain, duration: data.rampDuration)
            distortion.$positiveShapeParameter.ramp(to: data.positiveShapeParameter, duration: data.rampDuration)
            distortion.$negativeShapeParameter.ramp(to: data.negativeShapeParameter, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct TanhDistortionView: View {
    @StateObject var conductor = TanhDistortionConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Pregain",
                            parameter: self.$conductor.data.pregain,
                            range: 0.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Postgain",
                            parameter: self.$conductor.data.postgain,
                            range: 0.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Positive Shape Parameter",
                            parameter: self.$conductor.data.positiveShapeParameter,
                            range: -10.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Negative Shape Parameter",
                            parameter: self.$conductor.data.negativeShapeParameter,
                            range: -10.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.distortion, mix: conductor.dryWetMixer)
        }
        .padding()
        .navigationBarTitle(Text("Tanh Distortion"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct TanhDistortion_Previews: PreviewProvider {
    static var previews: some View {
        TanhDistortionView()
    }
}
