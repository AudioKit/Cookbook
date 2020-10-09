import AudioKit
import AVFoundation
import SwiftUI

struct ZitaReverbData {
    var predelay: AUValue = 60.0
    var crossoverFrequency: AUValue = 200.0
    var lowReleaseTime: AUValue = 3.0
    var midReleaseTime: AUValue = 2.0
    var dampingFrequency: AUValue = 6_000.0
    var equalizerFrequency1: AUValue = 315.0
    var equalizerLevel1: AUValue = 0.0
    var equalizerFrequency2: AUValue = 1_500.0
    var equalizerLevel2: AUValue = 0.0
    var dryWetMix: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ZitaReverbConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AudioEngine()
    let player = AudioPlayer()
    let reverb: ZitaReverb
    let dryWetMixer: DryWetMixer
    let playerPlot: NodeOutputPlot
    let reverbPlot: NodeOutputPlot
    let mixPlot: NodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        do {
            let file = try AVAudioFile(forReading: url!)
            buffer = try AVAudioPCMBuffer(file: file)!
        } catch {
            fatalError()
        }
        reverb = ZitaReverb(player)
        dryWetMixer = DryWetMixer(player, reverb)
        playerPlot = NodeOutputPlot(player)
        reverbPlot = NodeOutputPlot(reverb)
        mixPlot = NodeOutputPlot(dryWetMixer)
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

    @Published var data = ZitaReverbData() {
        didSet {
            reverb.$predelay.ramp(to: data.predelay, duration: data.rampDuration)
            reverb.$crossoverFrequency.ramp(to: data.crossoverFrequency, duration: data.rampDuration)
            reverb.$lowReleaseTime.ramp(to: data.lowReleaseTime, duration: data.rampDuration)
            reverb.$midReleaseTime.ramp(to: data.midReleaseTime, duration: data.rampDuration)
            reverb.$dampingFrequency.ramp(to: data.dampingFrequency, duration: data.rampDuration)
            reverb.$equalizerFrequency1.ramp(to: data.equalizerFrequency1, duration: data.rampDuration)
            reverb.$equalizerLevel1.ramp(to: data.equalizerLevel1, duration: data.rampDuration)
            reverb.$equalizerFrequency2.ramp(to: data.equalizerFrequency2, duration: data.rampDuration)
            reverb.$equalizerLevel2.ramp(to: data.equalizerLevel2, duration: data.rampDuration)
            reverb.$dryWetMix.ramp(to: data.dryWetMix, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
//        playerPlot.start()
//        reverbPlot.start()
//        mixPlot.start()

        do {
            try engine.start()
            // player stuff has to be done after start
//            player.scheduleBuffer(buffer, at: nil, options: .loops)
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct ZitaReverbView: View {
    @ObservedObject var conductor = ZitaReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            Text("Toggle").onTapGesture {
                if self.conductor.engine.avEngine.isRunning {
                    self.conductor.stop()
                    print("stop")
                } else {
                    self.conductor.start()
                    print("Start")
                }
            }
            VStack {
            ParameterSlider(text: "Predelay",
                            parameter: self.$conductor.data.predelay,
                            range: 0.0...200.0,
                            units: "Generic")
            ParameterSlider(text: "Crossover Frequency",
                            parameter: self.$conductor.data.crossoverFrequency,
                            range: 10.0...1_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Low Release Time",
                            parameter: self.$conductor.data.lowReleaseTime,
                            range: 0.0...10.0,
                            units: "Seconds")
            ParameterSlider(text: "Mid Release Time",
                            parameter: self.$conductor.data.midReleaseTime,
                            range: 0.0...10.0,
                            units: "Seconds")
            ParameterSlider(text: "Damping Frequency",
                            parameter: self.$conductor.data.dampingFrequency,
                            range: 10.0...22_050.0,
                            units: "Hertz")
            }
            ParameterSlider(text: "Equalizer Frequency1",
                            parameter: self.$conductor.data.equalizerFrequency1,
                            range: 10.0...1_000.0,
                            units: "Hertz")
            ParameterSlider(text: "Equalizer Level1",
                            parameter: self.$conductor.data.equalizerLevel1,
                            range: -100.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Equalizer Frequency2",
                            parameter: self.$conductor.data.equalizerFrequency2,
                            range: 10.0...22_050.0,
                            units: "Hertz")
            ParameterSlider(text: "Equalizer Level2",
                            parameter: self.$conductor.data.equalizerLevel2,
                            range: -100.0...10.0,
                            units: "Generic")
            ParameterSlider(text: "Dry Wet Mix",
                            parameter: self.$conductor.data.dryWetMix,
                            range: 0.0...1.0,
                            units: "Percent")
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
//            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.reverbPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Zita Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct ZitaReverb_Previews: PreviewProvider {
    static var previews: some View {
        ZitaReverbView()
    }
}
