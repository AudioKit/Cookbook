import AudioKit
import AVFoundation
import SwiftUI

//: Allows you to create a large variety of effects, usually reverbs or environments,
//: but it could also be for modeling.

struct ConvolutionData {
    var dryWetMix: AUValue = 0.5
    var stairwellDishMix: AUValue = 0.5
}

class ConvolutionConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer2()
    let buffer: AVAudioPCMBuffer
    let dishConvolution: Convolution!
    let stairwellConvolution: Convolution!
    var dryWetMixer: DryWetMixer!
    var mixer: DryWetMixer!

    @Published var data = ConvolutionData() {
        didSet {
            dryWetMixer.balance = data.dryWetMix
            mixer.balance = data.stairwellDishMix
        }
    }

    init() {
        buffer = Cookbook.sourceBuffer

        let bundle = Bundle.main

        guard let stairwell = bundle.url(forResource: "Impulse Responses/stairwell", withExtension: "wav"),
              let dish = bundle.url(forResource: "Impulse Responses/dish", withExtension: "wav") else { fatalError() }

        stairwellConvolution = Convolution(player,
                                           impulseResponseFileURL: stairwell,
                                           partitionLength: 8_192)
        dishConvolution = Convolution(player,
                                      impulseResponseFileURL: dish,
                                      partitionLength: 8_192)


        mixer = DryWetMixer(stairwellConvolution, dishConvolution, balance: 0.5)
        dryWetMixer = DryWetMixer(player, mixer, balance: 0.5)
        engine.output = dryWetMixer
    }

    func start() {

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
        stairwellConvolution.start()
        dishConvolution.start()

    }

    func stop() {
        engine.stop()
    }
}

struct ConvolutionView: View {
    @ObservedObject var conductor = ConvolutionConductor()
    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Dry Audio to Convolved",
                            parameter: self.$conductor.data.dryWetMix,
                            range: 0...1,
                            units: "%")
            ParameterSlider(text: "Stairwell to Dish",
                            parameter: self.$conductor.data.stairwellDishMix,
                            range: 0...1,
                            units: "%")
        }
        .padding()
        .navigationBarTitle(Text("Convolution"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }

}
