import AudioKit
import AudioKitEX
import AudioKitUI
import AVFAudio
import Keyboard
import SwiftUI
import Controls
import Tonic

class ArpeggiatorConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var instrument = AppleSampler()
    var sequencer: SequencerTrack!
    var midiCallback: CallbackInstrument!
    
    var heldNotes = [Int]()
    var isArpDescending = false
    var currentNote = 0
    var sequencerNoteLength = 1.0
    
    @Published var tempo : Float = 120.0 {
        didSet{
            sequencer.tempo = BPM(tempo)
        }
    }
    
    @Published var noteLength : Float = 1.0 {
        didSet{
            sequencerNoteLength = Double(noteLength)
            sequencer.clear()
            sequencer.add(noteNumber: 60, position: 0.0, duration: max(0.05, sequencerNoteLength * 0.24))
        }
    }
    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        //add notes to an array
        heldNotes.append(max(0,pitch.intValue))
    }
    
    func fireTimer() {
        for i in 0...127 {
            self.instrument.stop(noteNumber: MIDINoteNumber(i), channel: 0)
        }
        
        if self.heldNotes.count < 1 {
            return
        }
        
        if !isArpDescending {
          if heldNotes.max() != currentNote {
            currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
          } else {
            isArpDescending = true
            currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
          }
        } else {
          if heldNotes.min() != currentNote {
            currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
          } else {
            isArpDescending = false
            currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
          }
        }
        
        instrument.play(noteNumber: MIDINoteNumber(currentNote), velocity: 120, channel: 0)
    }
    
    func noteOff(pitch: Pitch) {
        heldNotes = heldNotes.filter { $0 != pitch.intValue }
    }
    
    init() {
        
        midiCallback = CallbackInstrument { status, note, vel in
            if status == 144 { //Note On
                self.fireTimer()
            } else if status == 128 { //Note Off
                //all notes off
                for i in 0...127 {
                    self.instrument.stop(noteNumber: MIDINoteNumber(i), channel: 0)
                }
            }
        }
        
        engine.output = PeakLimiter(Mixer(instrument, midiCallback), attackTime: 0.001, decayTime: 0.001, preGain: 0)
        
        do {
            if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sawPiano1", withExtension: "exs") {
                try instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
        
        sequencer = SequencerTrack(targetNode: midiCallback)
        sequencer.length = 0.25
        sequencer.loopEnabled = true
        sequencer.add(noteNumber: 60, position: 0.0, duration: 0.24)
        
        sequencer?.playFromStart()
    }
}

struct ArpeggiatorView: View {
    @StateObject var conductor = ArpeggiatorConductor()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NodeOutputView(conductor.instrument)
        HStack {
            CookbookKnob(text: "BPM", parameter: $conductor.tempo, range: 20.0...250.0)
            CookbookKnob(text: "Length", parameter: $conductor.noteLength, range: 0.0...1.0)
        }
        CookbookKeyboard(noteOn: conductor.noteOn,
                         noteOff: conductor.noteOff)
        .cookbookNavBarTitle("Arpeggiator")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
            conductor.sequencer.stop()
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

