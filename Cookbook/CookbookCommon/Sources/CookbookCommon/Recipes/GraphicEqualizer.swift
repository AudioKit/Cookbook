import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI

/* build a graphic equalizer from a set of equalizer filters

 Currently just using white noise so that the band can be visualized, but this example could be made a lot nicer. for music the following bands might be nicer:

 let filterBand1 = EqualizerFilter(player, centerFrequency: 32, bandwidth: 44.7, gain: 1.0)
 let filterBand2 = EqualizerFilter(filterBand2, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
 let filterBand3 = EqualizerFilter(filterBand3, centerFrequency: 125, bandwidth: 141, gain: 1.0)
 let filterBand4 = EqualizerFilter(filterBand4, centerFrequency: 250, bandwidth: 282, gain: 1.0)
 let filterBand5 = EqualizerFilter(filterBand5, centerFrequency: 500, bandwidth: 562, gain: 1.0)
 let filterBand6 = EqualizerFilter(filterBand6, centerFrequency: 1_000, bandwidth: 1_112, gain: 1.0)
 */

struct GraphicEqualizerData {
    var gain1: AUValue = 1.0
    var gain2: AUValue = 1.0
    var gain3: AUValue = 1.0
    var gain4: AUValue = 1.0
    var gain5: AUValue = 1.0
    var gain6: AUValue = 1.0
}

class GraphicEqualizerConductor: ObservableObject {
    var white = WhiteNoise()
    let fader: Fader

    let engine = AudioEngine()

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
        filterBand1 = EqualizerFilter(white, centerFrequency: 1000, bandwidth: 44.7, gain: 1.0)
        filterBand2 = EqualizerFilter(filterBand1, centerFrequency: 4000, bandwidth: 70.8, gain: 1.0)
        filterBand3 = EqualizerFilter(filterBand2, centerFrequency: 8000, bandwidth: 70.8, gain: 1.0)
        filterBand4 = EqualizerFilter(filterBand3, centerFrequency: 12000, bandwidth: 141, gain: 1.0)
        filterBand5 = EqualizerFilter(filterBand4, centerFrequency: 16000, bandwidth: 282, gain: 1.0)
        filterBand6 = EqualizerFilter(filterBand5, centerFrequency: 20000, bandwidth: 562, gain: 1.0)

        fader = Fader(filterBand6, gain: 0)
        engine.output = fader

    }
    func start() {
        white.start()
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct GraphicEqualizerView: View {
    @StateObject var conductor = GraphicEqualizerConductor()

    var body: some View {
        ScrollView {
            ParameterSlider(text: "Band 1",
                            parameter: self.$conductor.data.gain1,
                            range: 0 ... 2).padding()
            ParameterSlider(text: "Band 2",
                            parameter: self.$conductor.data.gain2,
                            range: 0 ... 2).padding()
            ParameterSlider(text: "Band 3",
                            parameter: self.$conductor.data.gain3,
                            range: 0 ... 2).padding()
            ParameterSlider(text: "Band 4",
                            parameter: self.$conductor.data.gain4,
                            range: 0 ... 2).padding()
            ParameterSlider(text: "Band 5",
                            parameter: self.$conductor.data.gain5,
                            range: 0 ... 2).padding()
            ParameterSlider(text: "Band 6",
                            parameter: self.$conductor.data.gain6,
                            range: 0 ... 2).padding()
            FFTView(conductor.fader)
        }.navigationBarTitle(Text("Graphic Equalizer"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct GraphicEqualizerView_Previews: PreviewProvider {
    static var previews: some View {
        GraphicEqualizerView()
    }
}
