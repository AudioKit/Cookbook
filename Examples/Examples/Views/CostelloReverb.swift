import AudioKit
import AVFoundation
import SwiftUI

struct CostelloReverbData {
    var isPlaying: Bool = false
        var feedback: AUValue = 0.6
    var cutoffFrequency: AUValue = 4_000.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class CostelloReverbConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let reverb: AKCostelloReverb
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let reverbPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        reverb = AKCostelloReverb(player)
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

    @Published var data = CostelloReverbData() {
        didSet {
            if data.isPlaying {
                player.play()
                reverb.$feedback.ramp(to: data.feedback, duration: data.rampDuration)
                reverb.$cutoffFrequency.ramp(to: data.cutoffFrequency, duration: data.rampDuration)
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

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

struct CostelloReverbView: View {
    @ObservedObject var conductor = CostelloReverbConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0.0...1.0).padding(5)
            ParameterSlider(text: "Cutoff Frequency",
                            parameter: self.$conductor.data.cutoffFrequency,
                            range: 12.0...5000.0).padding(5)
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
                PlotView(view: conductor.reverbPlot).clipped()
                Text("AKCostelloReverbed Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Costello Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
