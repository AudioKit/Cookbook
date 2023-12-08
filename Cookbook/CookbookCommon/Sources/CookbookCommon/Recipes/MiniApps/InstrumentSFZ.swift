import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Keyboard
import SoundpipeAudioKit
import SwiftUI
import Tonic
import DunneAudioKit

class InstrumentSFZConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = Sampler()
    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        instrument.play(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), velocity: 90, channel: 0)
    }
    
    func noteOff(pitch: Pitch) {
        instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
    }
    
    init() {
        // Load SFZ file with Dunne Sampler
        if let fileURL = Bundle.main.url(forResource: "Sounds/sqr", withExtension: "SFZ") {
            instrument.loadSFZ(url: fileURL)
        } else {
            Log("Could not find file")
        }
        instrument.masterVolume = 0.15
        engine.output = instrument
    }
}

struct InstrumentSFZView: View {
    @StateObject var conductor = InstrumentSFZConductor()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            ForEach(0...7, id: \.self){
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        HStack {
            ForEach(8...15, id: \.self){
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        HStack {
            ForEach(16...23, id: \.self){
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        HStack {
            ForEach(24...30, id: \.self){
                ParameterRow(param: conductor.instrument.parameters[$0])
            }
        }.padding(5)
        CookbookKeyboard(noteOn: conductor.noteOn,
                         noteOff: conductor.noteOff)
        .cookbookNavBarTitle("Instrument SFZ")
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
