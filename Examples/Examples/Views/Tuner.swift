import AudioKit
import SwiftUI
import AudioToolbox

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var noteNameWithSharps = "-"
    var noteNameWithFlats = "-"
}

class TunerConductor: Conductor, ObservableObject {

    let engine = AKEngine()
    lazy var mic = AKMicrophone(engine: engine.avEngine)
    let mixer = AKMixer()
    var tracker: AKPitchTap!
    var silence: AKBooster!

    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    @Published var data = TunerData()

    lazy var plot = AKNodeOutputPlot(nil)

    func start() {
        AKSettings.audioInputEnabled = true
        mic! >>> mixer
        tracker = AKPitchTap(mixer) { pitch, amp in
            DispatchQueue.main.async {
                self.data.pitch = pitch[0]
                self.data.amplitude = amp[0]

                var frequency = pitch[0]
                while frequency > Float(self.noteFrequencies[self.noteFrequencies.count - 1]) {
                    frequency /= 2.0
                }
                while frequency < Float(self.noteFrequencies[0]) {
                    frequency *= 2.0
                }

                var minDistance: Float = 10_000.0
                var index = 0

                for i in 0 ..< self.noteFrequencies.count {
                    let distance = fabsf(Float(self.noteFrequencies[i]) - frequency)
                    if distance < minDistance {
                        index = i
                        minDistance = distance
                    }
                }
                let octave = Int(log2f(pitch[0] / frequency))
                self.data.noteNameWithSharps = "\(self.noteNamesWithSharps[index])\(octave)"
                self.data.noteNameWithFlats = "\(self.noteNamesWithFlats[index])\(octave)"
            }
        }
        silence = AKBooster(mixer, gain: 0)

        do {
            engine.output = silence
            try engine.start()
            tracker.start()
            plot.node = mic
            plot.plotType = .rolling
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {

        engine.stop()
    }
}

struct TunerView: View {
    @ObservedObject var conductor = TunerConductor()

    var body: some View {
        VStack {
            HStack {
                Text("Frequency")
                Text("\(conductor.data.pitch, specifier: "%0.1f")")
            }
            HStack {
                Text("Amplitude")
                Text("\(conductor.data.amplitude, specifier: "%0.1f")")
            }
            HStack {
                Text("Note Name with #")
                Text(conductor.data.noteNameWithSharps)
            }
            HStack {
                Text("Note Name with Flats")
                Text(conductor.data.noteNameWithFlats)
            }

            PlotView(view: conductor.plot)


        }.navigationBarTitle(Text("Tuner"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}

