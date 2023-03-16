import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: Allows you to create a large variety of effects, usually reverbs or environments,
//: but it could also be for modeling.

struct ConvolutionData {
    var dryWetMix: AUValue = 0.5
    var stairwellDishMix: AUValue = 0.5
}

class ConvolutionConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
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
        player.buffer = buffer
        player.isLooping = true

        let bundle = Bundle.module

        guard let stairwell = bundle.url(forResource: "Impulse Responses/stairwell", withExtension: "wav"),
              let dish = bundle.url(forResource: "Impulse Responses/dish", withExtension: "wav") else { fatalError() }

        stairwellConvolution = Convolution(player,
                                           impulseResponseFileURL: stairwell,
                                           partitionLength: 8192)
        dishConvolution = Convolution(player,
                                      impulseResponseFileURL: dish,
                                      partitionLength: 8192)

        mixer = DryWetMixer(stairwellConvolution, dishConvolution, balance: 0.5)
        dryWetMixer = DryWetMixer(player, mixer, balance: 0.5)
        engine.output = dryWetMixer
        stairwellConvolution.start()
        dishConvolution.start()
    }
}

struct ConvolutionView: View {
    @StateObject var conductor = ConvolutionConductor()
    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                CookbookKnob(text: "Dry Audio to Convolved",
                                parameter: $conductor.data.dryWetMix,
                                range: 0 ... 1,
                                units: "%")
                CookbookKnob(text: "Stairwell to Dish",
                                parameter: $conductor.data.stairwellDishMix,
                                range: 0 ... 1,
                                units: "%")
            }
            DryWetMixView(dry: conductor.player,
                          wet: conductor.mixer,
                          mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Convolution")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
