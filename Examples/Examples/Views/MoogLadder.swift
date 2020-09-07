import AudioKit
import AVFoundation
import SwiftUI

//: One of the coolest filters available in AudioKit is the Moog Ladder.
//: It's based off of Robert Moog's iconic ladder filter, which was the
//: first implementation of a voltage - controlled filter used in an
//: analog synthesizer. As such, it was the first filter that gave the
//: ability to use voltage control to determine the cutoff frequency of the
//: filter. As we're dealing with a software implementation, and not an
//: analog synthesizer, we don't have to worry about dealing with
//: voltage control directly. However, by using this node, you can
//: emulate some of the sounds of classic analog synthesizers in your app.

struct MoogLadderData {
    var isPlaying: Bool = false
    var cutoffFrequency: AUValue = 1_000
    var resonance: AUValue = 0.5
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class MoogLadderConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let filter: AKMoogLadder
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let filterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = AKMoogLadder(player)
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

    @Published var data = MoogLadderData() {
        didSet {
            if data.isPlaying {
                player.play()
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

struct MoogLadderView: View {
    @ObservedObject var conductor = MoogLadderConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Cutoff Frequency (Hz)",
                            parameter: self.$conductor.data.cutoffFrequency, // taper of 4 would be nice on this slider
                            range: 40...5000).padding(5)
            ParameterSlider(text: "Resonance (%)",
                            parameter: self.$conductor.data.resonance,
                            range: 0.0...0.98).padding(5)
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
                Text("AKMoogLaddered Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Moog Ladder"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
