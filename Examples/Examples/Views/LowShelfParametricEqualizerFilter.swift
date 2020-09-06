import AudioKit
import AVFoundation
import SwiftUI

struct LowShelfParametricEqualizerFilterData {
    var isPlaying: Bool = false
    var cornerFrequency: AUValue = 1_000
    var gain: AUValue = 1.0
    var q: AUValue = 0.707
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class LowShelfParametricEqualizerFilterConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let equalizer: AKLowShelfParametricEqualizerFilter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let equalizerPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        equalizer = AKLowShelfParametricEqualizerFilter(player)
        dryWetMixer = AKDryWetMixer(player, equalizer)
        playerPlot = AKNodeOutputPlot(player)
        equalizerPlot = AKNodeOutputPlot(equalizer)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        equalizerPlot.plotType = .rolling
        equalizerPlot.color = .blue
        equalizerPlot.shouldFill = true
        equalizerPlot.shouldMirror = true
        equalizerPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = LowShelfParametricEqualizerFilterData() {
        didSet {
            if data.isPlaying {
                player.play()
                equalizer.$cornerFrequency.ramp(to: data.cornerFrequency, duration: data.rampDuration)
                equalizer.$gain.ramp(to: data.gain, duration: data.rampDuration)
                equalizer.$q.ramp(to: data.q, duration: data.rampDuration)
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

        }
    }

    func start() {
        playerPlot.start()
        equalizerPlot.start()
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

struct LowShelfParametricEqualizerFilterView: View {
    @ObservedObject var conductor = LowShelfParametricEqualizerFilterConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Corner Frequency (Hz)",
                            parameter: self.$conductor.data.cornerFrequency,
                            range: 12.0...20_000.0).padding(5)
            ParameterSlider(text: "Gain",
                            parameter: self.$conductor.data.gain,
                            range: 0.0...10.0).padding(5)
            ParameterSlider(text: "Q",
                            parameter: self.$conductor.data.q,
                            range: 0.0...2.0).padding(5)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...4,
                            format: "%0.2f").padding(5)
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            format: "%0.2f").padding(5)
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.playerPlot).clipped()
                Text("Input")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.equalizerPlot).clipped()
                Text("AKLowShelfParametricEqualizerFiltered Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Low Shelf Parametric Equalizer Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
