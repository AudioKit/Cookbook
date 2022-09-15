import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct GraphicEqualizerData {
    var gain1: AUValue = 1.0
    var gain2: AUValue = 1.0
    var gain3: AUValue = 1.0
    var gain4: AUValue = 1.0
    var gain5: AUValue = 1.0
    var gain6: AUValue = 1.0
}

class GraphicEqualizerConductor: ObservableObject, ProcessesPlayerInput {
    let fader: Fader

    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer

    let filterBand1: EqualizerFilter
    let filterBand2: EqualizerFilter
    let filterBand3: EqualizerFilter
    let filterBand4: EqualizerFilter
    let filterBand5: EqualizerFilter
    let filterBand6: EqualizerFilter

    @Published var data = GraphicEqualizerData() {
        didSet {
            filterBand1.gain = data.gain1
            filterBand2.gain = data.gain2
            filterBand3.gain = data.gain3
            filterBand4.gain = data.gain4
            filterBand5.gain = data.gain5
            filterBand6.gain = data.gain6
        }
    }

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        filterBand1 = EqualizerFilter(player, centerFrequency: 32, bandwidth: 44.7, gain: 1.0)
        filterBand2 = EqualizerFilter(filterBand1, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
        filterBand3 = EqualizerFilter(filterBand2, centerFrequency: 125, bandwidth: 141, gain: 1.0)
        filterBand4 = EqualizerFilter(filterBand3, centerFrequency: 250, bandwidth: 282, gain: 1.0)
        filterBand5 = EqualizerFilter(filterBand4, centerFrequency: 500, bandwidth: 562, gain: 1.0)
        filterBand6 = EqualizerFilter(filterBand5, centerFrequency: 1_000, bandwidth: 1_112, gain: 1.0)

        fader = Fader(filterBand6, gain: 0.4)
        engine.output = fader
    }
}

struct GraphicEqualizerView: View {
    @StateObject var conductor = GraphicEqualizerConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                CookbookKnob(text: "Band 1",
                                parameter: $conductor.data.gain1,
                                range: 0 ... 20)
                CookbookKnob(text: "Band 2",
                                parameter: $conductor.data.gain2,
                             range: 0 ... 20)
                CookbookKnob(text: "Band 3",
                                parameter: $conductor.data.gain3,
                             range: 0 ... 20)
                CookbookKnob(text: "Band 4",
                                parameter: $conductor.data.gain4,
                             range: 0 ... 20)
                CookbookKnob(text: "Band 5",
                                parameter: $conductor.data.gain5,
                             range: 0 ... 20)
                CookbookKnob(text: "Band 6",
                                parameter: $conductor.data.gain6,
                             range: 0 ... 20)
            }.padding(5)
            FFTView(conductor.fader)
        }.cookbookNavBarTitle("Graphic Equalizer")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}
