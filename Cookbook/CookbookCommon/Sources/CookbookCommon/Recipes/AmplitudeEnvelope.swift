import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

//: ## Amplitude Envelope
//: A surprising amount of character can be added to a sound by changing its amplitude over time.
//: A very common means of defining the shape of amplitude is to use an ADSR envelope which stands for
//: Attack, Sustain, Decay, Release.
//: * Attack is the amount of time it takes a sound to reach its maximum volume.  An example of a fast attack is a
//:   piano, where as a cello can have a longer attack time.
//: * Decay is the amount of time after which the peak amplitude is reached for a lower amplitude to arrive.
//: * Sustain is not a time, but a percentage of the peak amplitude that will be the the sustained amplitude.
//: * Release is the amount of time after a note is let go for the sound to die away to zero.
class AmplitudeEnvelopeConductor: ObservableObject, KeyboardDelegate {
    let engine = AudioEngine()
    var currentNote = 0

    func noteOn(note: MIDINoteNumber) {
        if note != currentNote {
            env.closeGate()
        }
        osc.frequency = note.midiNoteToFrequency()
        env.openGate()
    }

    func noteOff(note: MIDINoteNumber) {
        env.closeGate()
    }

    var osc: Oscillator
    var env: AmplitudeEnvelope
    var fader: Fader

    init() {
        osc = Oscillator()
        env = AmplitudeEnvelope(osc)
        fader = Fader(env)
        osc.amplitude = 1
        engine.output = fader
    }

    func start() {
        osc.start()
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        osc.stop()
        engine.stop()
    }
}

struct AmplitudeEnvelopeView: View {
    @StateObject var conductor = AmplitudeEnvelopeConductor()

    var body: some View {
        VStack {
            ADSRWidget { att, dec, sus, rel in
                self.conductor.env.attackDuration = att
                self.conductor.env.decayDuration = dec
                self.conductor.env.sustainLevel = sus
                self.conductor.env.releaseDuration = rel
            }
            NodeOutputView(conductor.env)
            NodeRollingView(conductor.fader, color: .red)
            KeyboardControl(firstOctave: 0,
                            octaveCount: 2,
                            polyphonicMode: false,
                            delegate: conductor)

        }.navigationBarTitle(Text("Amplitude Envelope"))
            .onAppear {
                self.conductor.start()
            }
            .onDisappear {
                self.conductor.stop()
            }
    }
}

struct AmplitudeEnvelopeView_Previews: PreviewProvider {
    static var previews: some View {
        AmplitudeEnvelopeView()
    }
}
