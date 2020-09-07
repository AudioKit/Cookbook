import AudioKit
import AVFoundation
import SwiftUI

struct ClipperData {
    var isPlaying: Bool = false
    var limit: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class ClipperConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let clipper: AKClipper
    let dryWetMixer: AKDryWetMixer
    let balancer: AKBalancer
    let playerPlot: AKNodeOutputPlot
    let clipperPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        clipper = AKClipper(player)
        dryWetMixer = AKDryWetMixer(player, clipper)
        balancer = AKBalancer(dryWetMixer, comparator: player)
        playerPlot = AKNodeOutputPlot(player)
        clipperPlot = AKNodeOutputPlot(clipper)
        mixPlot = AKNodeOutputPlot(balancer)
        engine.output = balancer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        clipperPlot.plotType = .rolling
        clipperPlot.color = .blue
        clipperPlot.shouldFill = true
        clipperPlot.shouldMirror = true
        clipperPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = ClipperData() {
        didSet {
            if data.isPlaying {
                player.play()
                clipper.$limit.ramp(to: data.limit, duration: data.rampDuration)
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

        }
    }

    func start() {
        playerPlot.start()
        clipperPlot.start()
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

struct ClipperView: View {
    @ObservedObject var conductor = ClipperConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Threshold",
                            parameter: self.$conductor.data.limit,
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
                PlotView(view: conductor.clipperPlot).clipped()
                Text("AKClippered Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Clipper"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
