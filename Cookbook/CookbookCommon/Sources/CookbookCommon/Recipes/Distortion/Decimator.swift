import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: Decimation is a type of digital distortion like bit crushing,
//: but instead of directly stating what bit depth and sample rate you want,
//: it is done through setting "decimation" and "rounding" parameters.

struct DecimatorData {
    var decimation: AUValue = 50
    var rounding: AUValue = 50
    var mix: AUValue = 100
}

class DecimatorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let decimator: Decimator
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        decimator = Decimator(player)
        decimator.finalMix = 100

        engine.output = decimator
    }

    @Published var data = DecimatorData() {
        didSet {
            decimator.decimation = data.decimation
            decimator.rounding = data.rounding
            decimator.finalMix = data.mix
        }
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct DecimatorView: View {
    @StateObject var conductor = DecimatorConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Decimation",
                            parameter: self.$conductor.data.decimation,
                            range: 0 ... 100,
                            units: "Percent-0-100")
            ParameterSlider(text: "Rounding",
                            parameter: self.$conductor.data.rounding,
                            range: 0 ... 100,
                            units: "Percent-0-100")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.mix,
                            range: 0 ... 100,
                            units: "Percent-0-100")
        }
        .padding()
        .cookbookNavBarTitle("Decimator")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Decimator_Previews: PreviewProvider {
    static var previews: some View {
        DecimatorView()
    }
}
