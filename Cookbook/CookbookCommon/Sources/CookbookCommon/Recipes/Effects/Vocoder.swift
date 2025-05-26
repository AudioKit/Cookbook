import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI
import Tonic

class VocoderConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let vocoder: Vocoder
    let buffer: AVAudioPCMBuffer
    
    var osc = MorphingOscillator(index: 2.5)

    func noteOn(pitch: Pitch, point _: CGPoint) {
        isPlaying = true
        osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
    }
    
    func noteOff(pitch _: Pitch) {
        isPlaying = false
    }
    
    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? osc.start() : osc.stop() }
    }
    
    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true
        osc.amplitude = 0.5

        vocoder = Vocoder(player, excitation: osc)
        engine.output = vocoder
        
        vocoder.attackTime     = 0.001
        vocoder.releaseTime    = 0.02
        vocoder.bandwidthRatio = 0.1
    }
}

struct VocoderView: View {
    @StateObject var conductor = VocoderConductor()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.vocoder.parameters) {
                    ParameterRow(param: $0)
                }
            }
            NodeOutputView(conductor.player)
            CookbookKeyboard(noteOn: conductor.noteOn,
                             noteOff: conductor.noteOff)
        }
        .padding()
        .cookbookNavBarTitle("Vocoder")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}
