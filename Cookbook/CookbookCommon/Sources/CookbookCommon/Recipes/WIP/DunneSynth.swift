import AudioKit
import DunneAudioKit
import AudioKitEX
import AudioKitUI
import AVFAudio
import Keyboard
import SwiftUI
import Controls
import Tonic

class DunneSynthConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = Synth()
    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 120, channel: 0)
    }
    
    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
    }
    
    init() {
        engine.output = PeakLimiter(instrument, attackTime: 0.001, decayTime: 0.001, preGain: 0)
        
        //Remove pops
        instrument.releaseDuration = 0.01
        instrument.filterReleaseDuration = 10.0
        instrument.filterStrength = 40.0
    }
}

struct DunneSynthView: View {
    @StateObject var conductor = DunneSynthConductor()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NodeOutputView(conductor.instrument)
        HStack {
            ForEach(0...6, id: \.self){
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        HStack {
            ForEach(7...13, id: \.self){
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        CookbookKeyboard(noteOn: conductor.noteOn,
                         noteOff: conductor.noteOff)
        .cookbookNavBarTitle("Dunne Synth")
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


