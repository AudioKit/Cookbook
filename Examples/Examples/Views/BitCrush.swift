import AudioKit
import AVFoundation
import SwiftUI

struct AKBitCrusherData {
    var isPlaying: Bool = false
        var bitDepth: AUValue = 8
    var sampleRate: AUValue = 10_000
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.0
}

class AKBitCrusherConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let bitcrusher: AKBitCrusher
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let bitcrusherPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        bitcrusher = AKBitCrusher(player)
        dryWetMixer = AKDryWetMixer(player, bitcrusher)
        playerPlot = AKNodeOutputPlot(player)
        bitcrusherPlot = AKNodeOutputPlot(bitcrusher)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        bitcrusherPlot.plotType = .rolling
        bitcrusherPlot.color = .blue
        bitcrusherPlot.shouldFill = true
        bitcrusherPlot.shouldMirror = true
        bitcrusherPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = AKBitCrusherData() {
        didSet {
            if data.isPlaying {
                player.play()
                bitcrusher.$bitDepth.ramp(to: data.bitDepth, duration: data.rampDuration)
                bitcrusher.$sampleRate.ramp(to: data.sampleRate, duration: data.rampDuration)
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

        }
    }

    func start() {
        playerPlot.start()
        bitcrusherPlot.start()
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

struct AKBitCrusherView: View {
    @ObservedObject var conductor = AKBitCrusherConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Bit Depth",
                            parameter: self.$conductor.data.bitDepth,
                            range: 1...24).padding(5)
            ParameterSlider(text: "Sample Rate (Hz)",
                            parameter: self.$conductor.data.sampleRate,
                            range: 0.0...20_000.0).padding(5)
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
                PlotView(view: conductor.bitcrusherPlot).clipped()
                Text("AKBitCrushered Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
