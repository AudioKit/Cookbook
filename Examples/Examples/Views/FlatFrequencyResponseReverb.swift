import AudioKit
import AVFoundation
import SwiftUI

struct FlatFrequencyResponseReverbData {
    var reverbDuration: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class FlatFrequencyResponseReverbConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let reverb: AKFlatFrequencyResponseReverb
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let reverbPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        reverb = AKFlatFrequencyResponseReverb(player)
        dryWetMixer = AKDryWetMixer(player, reverb)
        playerPlot = AKNodeOutputPlot(player)
        reverbPlot = AKNodeOutputPlot(reverb)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        reverbPlot.plotType = .rolling
        reverbPlot.color = .blue
        reverbPlot.shouldFill = true
        reverbPlot.shouldMirror = true
        reverbPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = FlatFrequencyResponseReverbData() {
        didSet {
            reverb.$reverbDuration.ramp(to: data.reverbDuration, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        reverbPlot.start()
        mixPlot.start()

        do {
            try engine.start()
            // player stuff has to be done after start
            player.scheduleBuffer(buffer, at: nil, options: .loops)
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct FlatFrequencyResponseReverbView: View {
    @ObservedObject var conductor = FlatFrequencyResponseReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Reverb Duration",
                            parameter: self.$conductor.data.reverbDuration,
                            range: 0...10,
                            units: "Seconds")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.reverbPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Flat Frequency Response Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct FlatFrequencyResponseReverb_Previews: PreviewProvider {
    static var previews: some View {
        FlatFrequencyResponseReverbView()
    }
}
