import AudioKit
import AVFoundation
import SwiftUI

struct ThreePoleLowpassFilterData {
    var isPlaying: Bool = false
    var distortion: AUValue = 0.5
    var cutoffFrequency: AUValue = 1_500
    var resonance: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ThreePoleLowpassFilterConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let filter: AKThreePoleLowpassFilter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let filterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = AKThreePoleLowpassFilter(player)
        dryWetMixer = AKDryWetMixer(player, filter)
        playerPlot = AKNodeOutputPlot(player)
        filterPlot = AKNodeOutputPlot(filter)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        filterPlot.plotType = .rolling
        filterPlot.color = .blue
        filterPlot.shouldFill = true
        filterPlot.shouldMirror = true
        filterPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = ThreePoleLowpassFilterData() {
        didSet {
            if data.isPlaying {
                player.play()
                filter.$distortion.ramp(to: data.distortion, duration: data.rampDuration)
                filter.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
                filter.$resonance.ramp(to: data.resonance, duration: data.rampDuration)
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
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

struct ThreePoleLowpassFilterView: View {
    @ObservedObject var conductor = ThreePoleLowpassFilterConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Distortion (%)",
                            parameter: self.$conductor.data.distortion,
                            range: 0.0...2.0).padding(5)
            ParameterSlider(text: "Cutoff Frequency (Hz)",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...5000.0).padding(5)
            ParameterSlider(text: "Resonance (%)",
                            parameter: self.$conductor.data.resonance,
                            range: 0.0...1.0).padding(5)
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
                PlotView(view: conductor.filterPlot).clipped()
                Text("AKThreePoleLowpassFiltered Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Three Pole Lowpass Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
