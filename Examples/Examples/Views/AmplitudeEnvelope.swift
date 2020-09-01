import AudioKit
import SwiftUI
import AudioToolbox

class AmplitudeEnvelopeConductor: Conductor, ObservableObject, AKKeyboardDelegate {

    let engine = AKEngine()
    var currentNote = 0

    func noteOn(note: MIDINoteNumber) {
        if note != currentNote {
            print("stop")
            env.stop()
        }
        osc.frequency = note.midiNoteToFrequency()
        env.start()
    }

    func noteOff(note: MIDINoteNumber) {
        env.stop()
    }

    var osc = AKOscillator()
    var env = AKAmplitudeEnvelope()

    lazy var plot = AKNodeOutputPlot(nil)

    func start() {
        osc >>> env
        osc.amplitude = 1
        engine.output = env
        osc.start()
        do {
            try engine.start()
            plot.plotType = .rolling
            plot.node = env
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        osc.stop()
        engine.stop()
    }
}

struct AmplitudeEnvelopeView: View {
    @ObservedObject var conductor  = AmplitudeEnvelopeConductor()

    var body: some View {
        VStack {
            ADSRView { att, dec, sus, rel in
                self.conductor.env.attackDuration = att
                self.conductor.env.decayDuration = dec
                self.conductor.env.sustainLevel = sus
                self.conductor.env.releaseDuration = rel
            }
            PlotView(view: conductor.plot)
            KeyboardView(delegate: conductor)

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

