import AudioKit
import AVFoundation
import SwiftUI

struct DynamicRangeCompressorData {
    var isPlaying: Bool = false
    var ratio: AUValue = 1
    var threshold: AUValue = 0.0
    var attackDuration: AUValue = 0.1
    var releaseDuration: AUValue = 0.1
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class DynamicRangeCompressorConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let compressor: AKDynamicRangeCompressor
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let compressorPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        compressor = AKDynamicRangeCompressor(player)
        dryWetMixer = AKDryWetMixer(player, compressor)
        playerPlot = AKNodeOutputPlot(player)
        compressorPlot = AKNodeOutputPlot(compressor)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        compressorPlot.plotType = .rolling
        compressorPlot.color = .blue
        compressorPlot.shouldFill = true
        compressorPlot.shouldMirror = true
        compressorPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = DynamicRangeCompressorData() {
        didSet {
            if data.isPlaying {
                player.play()
                compressor.$ratio.ramp(to: data.ratio, duration: data.rampDuration)
                compressor.$threshold.ramp(to: data.threshold, duration: data.rampDuration)
                compressor.$attackDuration.ramp(to: data.attackDuration, duration: data.rampDuration)
                compressor.$releaseDuration.ramp(to: data.releaseDuration, duration: data.rampDuration)
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

        }
    }

    func start() {
        playerPlot.start()
        compressorPlot.start()
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

struct DynamicRangeCompressorView: View {
    @ObservedObject var conductor = DynamicRangeCompressorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Ratio to compress with, a value > 1 will compress",
                            parameter: self.$conductor.data.ratio,
                            range: 0.01...100.0).padding(5)
            ParameterSlider(text: "Threshold (in dB) 0 = max",
                            parameter: self.$conductor.data.threshold,
                            range: -100.0...0.0).padding(5)
            ParameterSlider(text: "Attack duration",
                            parameter: self.$conductor.data.attackDuration,
                            range: 0.0...1.0).padding(5)
            ParameterSlider(text: "Release duration",
                            parameter: self.$conductor.data.releaseDuration,
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
                PlotView(view: conductor.compressorPlot).clipped()
                Text("AKDynamicRangeCompressored Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Dynamic Range Compressor"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
