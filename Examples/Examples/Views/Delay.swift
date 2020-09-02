import AudioKit
import AVFoundation
import SwiftUI

struct DelayData {
    var isPlaying: Bool = false
    var time: AUValue = 0.0
    var feedback: AUValue = 0.0
    var balance: AUValue = 0.0
}

class DelayConductor: ObservableObject {
    let engine = AKEngine()
    var player = AKPlayer()
    let delay = AKDelay()
    var dryWetMixer: AKDryWetMixer!
    var buffer: AVAudioPCMBuffer!

    lazy var playerPlot = AKNodeOutputPlot()
    lazy var delayPlot = AKNodeOutputPlot()
    lazy var mixPlot = AKNodeOutputPlot()

    @Published var data = DelayData() {
        didSet {
            if data.isPlaying {
                player.play()
                delay.time = TimeInterval(data.time)
                delay.feedback = data.feedback
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

        }
    }

    func start() {
        do {
            let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
            let file = try AVAudioFile(forReading: url!)
            let buffer = try! AVAudioPCMBuffer(file: file)!

            player >>> delay
            dryWetMixer = AKDryWetMixer(player, delay)
            delay.feedback = 0.9
            delay.time = 0.01

            // We're not using delay's built in dry wet mix because
            // we are tapping the wet result so it can be plotted,
            // so just hard coding the delay to fully on
            delay.dryWetMix = 1.0

            engine.output = dryWetMixer
            try engine.start()

            // player stuff has to be done after start
            player.scheduleBuffer(buffer, at: nil, options: .loops)

            playerPlot.node = player
            playerPlot.plotType = .rolling
            playerPlot.shouldFill = true
            playerPlot.shouldMirror = true
            playerPlot.setRollingHistoryLength(128)
            delayPlot.node = delay
            delayPlot.plotType = .rolling
            delayPlot.color = .blue
            delayPlot.shouldFill = true
            delayPlot.shouldMirror = true
            delayPlot.setRollingHistoryLength(128)
            mixPlot.node = dryWetMixer
            mixPlot.color = .purple
            mixPlot.shouldFill = true
            mixPlot.shouldMirror = true
            mixPlot.plotType = .rolling
            mixPlot.setRollingHistoryLength(128)


        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct DelayView: View {
    @ObservedObject var conductor = DelayConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Time",
                            parameter: self.$conductor.data.time,
                            range: 0...1,
                            format: "%0.2f")
            ParameterSlider(text: "Feedback",
                            parameter: self.$conductor.data.feedback,
                            range: 0...0.99,
                            format: "%0.2f")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            format: "%0.2f")
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.playerPlot).clipped()
                Text("Input")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.delayPlot).clipped()
                Text("Delayed Signal")
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
