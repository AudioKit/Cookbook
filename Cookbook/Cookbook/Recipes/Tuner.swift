import AudioKit
import AudioToolbox
import SwiftUI

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var noteNameWithSharps = "-"
    var noteNameWithFlats = "-"
}

class TunerConductor: ObservableObject {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode
    var tappableNode1: Mixer
    var tappableNode2: Mixer
    var tappableNode3: Mixer
    var tracker: PitchTap!
    var silence: Fader

    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    @Published var data = TunerData()

    let rollingPlot: NodeOutputPlot
    let bufferPlot: NodeOutputPlot
    let fftPlot: NodeFFTPlot

    func update(_ pitch: AUValue, _ amp: AUValue) {
        data.pitch = pitch
        data.amplitude = amp

        var frequency = pitch
        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
            frequency /= 2.0
        }
        while frequency < Float(noteFrequencies[0]) {
            frequency *= 2.0
        }

        var minDistance: Float = 10_000.0
        var index = 0

        for possibleIndex in 0 ..< noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[possibleIndex]) - frequency)
            if distance < minDistance {
                index = possibleIndex
                minDistance = distance
            }
        }
        let octave = Int(log2f(pitch / frequency))
        data.noteNameWithSharps = "\(noteNamesWithSharps[index])\(octave)"
        data.noteNameWithFlats = "\(noteNamesWithFlats[index])\(octave)"
    }

    init() {
        guard let input = engine.input else {
            fatalError()
        }

        mic = input
        tappableNode1 = Mixer(mic)
        tappableNode2 = Mixer(tappableNode1)
        tappableNode3 = Mixer(tappableNode2)
        silence = Fader(tappableNode3, gain: 0)
        engine.output = silence

        rollingPlot = NodeOutputPlot(tappableNode1)
        bufferPlot = NodeOutputPlot(tappableNode2)
        fftPlot = NodeFFTPlot(tappableNode3)

        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
    }

    func start() {
        Settings.audioInputEnabled = true

        do {
            try engine.start()
            tracker.start()
            rollingPlot.plotType = .rolling
            rollingPlot.shouldFill = true
            rollingPlot.shouldMirror = true
            rollingPlot.start()
            bufferPlot.plotType = .buffer
            bufferPlot.color = .green
            bufferPlot.start()
            fftPlot.gain = 100
            fftPlot.color = .blue
            fftPlot.start()
        } catch let err {
            Log(err)
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
    @Environment(\.presentationMode) var presentationMode
    var conductor: TunerConductor

    func getDevices() -> [Device] {
        return AudioEngine.inputDevices?.compactMap { $0 } ?? []
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ForEach(getDevices(), id: \.self) { device in
                Text(device == self.conductor.engine.inputDevice ? "* \(device.name)" : "\(device.name)").onTapGesture {
                    do {
                        try AudioEngine.setInputDevice(device)
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
