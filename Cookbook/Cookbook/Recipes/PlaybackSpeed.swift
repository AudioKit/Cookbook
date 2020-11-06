import AudioKit
import AVFoundation
import SwiftUI

// This recipe uses the VariSpeed node to change the playback speed of a file (which also affects the pitch)
struct PlaybackSpeedData {
    var rate: AUValue = 2.0
}

class PlaybackSpeedConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer2()
    let variSpeed: VariSpeed
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer

        variSpeed = VariSpeed(player)
        engine.output = variSpeed
    }

    @Published var data = PlaybackSpeedData() {
        didSet {
            // When AudioKit uses an Apple AVAudioUnit, like the case here, the values can't be ramped
            variSpeed.rate = data.rate
        }
    }

    func start() {
        variSpeed.rate = 2.0

        do { try engine.start() } catch let err { Log(err) }
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func stop() {
        engine.stop()
    }
}

struct PlaybackSpeedView: View {
    @ObservedObject var conductor = PlaybackSpeedConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Rate",
                            parameter: self.$conductor.data.rate,
                            range: 0.3125...5,
                            units: "Generic")
        }
        .padding()
        .navigationBarTitle(Text("Playback Speed"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct PlaybackSpeed_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackSpeedView()
    }
}
