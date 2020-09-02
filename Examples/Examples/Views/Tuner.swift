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
    var tappableNode1 = AKMixer()
    var tappableNode2 = AKMixer()
    var tappableNode3 = AKMixer()
    var tracker: AKPitchTap!
    var silence: AKBooster!

    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    @Published var data = TunerData()

    lazy var rollingPlot = AKNodeOutputPlot(tappableNode1)
    lazy var bufferPlot = AKNodeOutputPlot(tappableNode2)
    lazy var fftPlot = AKNodeFFTPlot(tappableNode3)

    func start() {
        AKSettings.audioInputEnabled = true
        tappableNode1.addInput(mic!)
        tappableNode2.addInput(tappableNode2)
        tappableNode3.addInput(tappableNode3)
        tracker = AKPitchTap(mic) { pitch, amp in
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
        silence = AKBooster(tappableNode3, gain: 0)

        do {
            engine.output = silence
            try engine.start()
            tracker.start()
            rollingPlot.plotType = .rolling
            rollingPlot.shouldFill = true
            rollingPlot.shouldMirror = true
            bufferPlot.plotType = .buffer
            bufferPlot.color = .green
            fftPlot.gain = 100
            fftPlot.color = .blue
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
    @State private var showDevices: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("Frequency")
                Spacer()
                Text("\(conductor.data.pitch, specifier: "%0.1f")")
            }.padding()
            HStack {
                Text("Amplitude")
                Spacer()
                Text("\(conductor.data.amplitude, specifier: "%0.1f")")
            }.padding()
            HStack {
                Text("Note Name")
                Spacer()
                Text("\(conductor.data.noteNameWithSharps) / \(conductor.data.noteNameWithFlats)")
            }.padding()
            Button("\(conductor.engine.inputDevice?.name ?? "Choose Mic")") {
                self.showDevices = true
            }

            PlotView(view: conductor.rollingPlot).clipped()
            PlotView(view: conductor.bufferPlot).clipped()
            FFTPlotView(view: conductor.fftPlot).clipped()

        }.navigationBarTitle(Text("Tuner"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }.sheet(isPresented: $showDevices,
                onDismiss: { print("finished!") },
                content: { MySheet(conductor: self.conductor) })
    }
}

struct MySheet: View {
    @Environment (\.presentationMode) var presentationMode
    var conductor: TunerConductor

    func getDevices() -> [AKDevice] {
        return AKEngine.inputDevices?.compactMap { $0 } ?? []
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ForEach(getDevices(), id: \.self) { device in
                Text(device == self.conductor.engine.inputDevice ? "* \(device.name)" : "\(device.name)").onTapGesture {
                    do {
                        try self.conductor.mic?.setDevice(device)
                    } catch let err {
                        print(err)
                    }
                }
            }
            Text("Dismiss")
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
            }
            Spacer()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}


struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}

