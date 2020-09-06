import AudioKit
import AVFoundation
import SwiftUI

struct TanhDistortionData {
    var isPlaying: Bool = false
    var pregain: AUValue = 2.0
    var postgain: AUValue = 0.5
    var positiveShapeParameter: AUValue = 0.0
    var negativeShapeParameter: AUValue = 0.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class TanhDistortionConductor: ObservableObject {
    let engine = AKEngine()
    let player = AKPlayer()
    let distortion: AKTanhDistortion
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let distortionPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        distortion = AKTanhDistortion(player)
        dryWetMixer = AKDryWetMixer(player, distortion)
        playerPlot = AKNodeOutputPlot(player)
        distortionPlot = AKNodeOutputPlot(distortion)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        distortionPlot.plotType = .rolling
        distortionPlot.color = .blue
        distortionPlot.shouldFill = true
        distortionPlot.shouldMirror = true
        distortionPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = TanhDistortionData() {
        didSet {
            if data.isPlaying {
                player.play()
                distortion.$pregain.ramp(to: data.pregain, duration: data.rampDuration)
                distortion.$postgain.ramp(to: data.postgain, duration: data.rampDuration)
                distortion.$positiveShapeParameter.ramp(to: data.positiveShapeParameter, duration: data.rampDuration)
                distortion.$negativeShapeParameter.ramp(to: data.negativeShapeParameter, duration: data.rampDuration)
                dryWetMixer.balance = data.balance

            } else {
                player.pause()
            }

        }
    }

    func start() {
        playerPlot.start()
        distortionPlot.start()
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

struct TanhDistortionView: View {
    @ObservedObject var conductor = TanhDistortionConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Pregain",
                            parameter: self.$conductor.data.pregain,
                            range: 0.0...10.0).padding(5)
            ParameterSlider(text: "Postgain",
                            parameter: self.$conductor.data.postgain,
                            range: 0.0...10.0).padding(5)
            ParameterSlider(text: "Positive Shape Parameter",
                            parameter: self.$conductor.data.positiveShapeParameter,
                            range: -10.0...10.0).padding(5)
            ParameterSlider(text: "Negative Shape Parameter",
                            parameter: self.$conductor.data.negativeShapeParameter,
                            range: -10.0...10.0).padding(5)
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
                PlotView(view: conductor.distortionPlot).clipped()
                Text("AKTanhDistortioned Signal")
            }
            ZStack(alignment:.topLeading) {
                PlotView(view: conductor.mixPlot).clipped()
                Text("Mixed Output")
            }
        }
        .padding()
        .navigationBarTitle(Text("Tanh Distortion"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
