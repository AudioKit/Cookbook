import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI
import Tonic

class TalkboxConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let talkbox: Talkbox
    let buffer: AVAudioPCMBuffer
    
    var osc = DynamicOscillator()

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

        talkbox = Talkbox(player, excitation: osc)
        engine.output = talkbox
    }
}

struct TalkboxView: View {
    @StateObject var conductor = TalkboxConductor()

    var body: some View {
        VStack {
            PlayerControls(conductor: conductor)
            HStack {
                ForEach(conductor.talkbox.parameters) {
                    ParameterRow(param: $0)
                }
            }
            NodeOutputView(conductor.player)
            CookbookKeyboard(noteOn: conductor.noteOn,
                             noteOff: conductor.noteOff)
        }
        .padding()
        .cookbookNavBarTitle("Talkbox")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
