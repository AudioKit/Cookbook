import AudioKit
import AVFoundation
import SwiftUI

struct BandPassButterworthFilterData {
    var isPlaying: Bool = false
    var centerFrequency: AUValue = 2_000.0
    var bandwidth: AUValue = 100.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class BandPassButterworthFilterConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let filter: AKBandPassButterworthFilter
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let filterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = AKBandPassButterworthFilter(player)
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

    @Published var data = BandPassButterworthFilterData() {
        didSet {
            if data.isPlaying {
                player.play()
                filter.$centerFrequency.ramp(to: data.centerFrequency, duration: data.rampDuration)
                filter.$bandwidth.ramp(to: data.bandwidth, duration: data.rampDuration)
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

struct BandPassButterworthFilterView: View {
    @ObservedObject var conductor = BandPassButterworthFilterConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Center Frequency (Hz)",
                            parameter: self.$conductor.data.centerFrequency,
                            range: 12.0...5000.0).padding(5)
            ParameterSlider(text: "Bandwidth (Hz)",
                            parameter: self.$conductor.data.bandwidth,
                            range: 0.0...1000.0).padding(5)
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
                Text("AKBandPassButterworthFiltered Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Band Pass Butterworth Filter"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
