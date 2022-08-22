import AudioKit
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

struct CompressorData {
    var balance: AUValue = 0.5
}

class CompressorConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let compressor: Compressor
    let dryWetMixer: DryWetMixer
    let buffer: AVAudioPCMBuffer

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        compressor = Compressor(player)

        dryWetMixer = DryWetMixer(player, compressor)
        engine.output = dryWetMixer
    }

    @Published var data = CompressorData() {
        didSet {
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct CompressorView: View {
    @StateObject var conductor = CompressorConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack(spacing: 50) {
                ForEach(conductor.compressor.parameters) {
                    ParameterEditor2(param: $0)
                }
            }
            ParameterSlider(text: "Mix",
                            parameter: self.$conductor.data.balance,
                            range: 0 ... 1,
                            units: "%")
            DryWetMixView(dry: conductor.player, wet: conductor.compressor, mix: conductor.dryWetMixer)
        }
        .padding()
        .cookbookNavBarTitle("Compressor")
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
