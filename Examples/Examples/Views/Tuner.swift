import AudioKit
import SwiftUI
import AudioToolbox

struct TunerData {
    var pitch: Float = 0.0
    var amplitude: Float = 0.0
    var noteNameWithSharps = "-"
    var noteNameWithFlats = "-"
}

class TunerConductor: ObservableObject {

    let engine = AKEngine()
    var mic: AKEngine.InputNode
    var tappableNode1: AKMixer
    var tappableNode2: AKMixer
    var tappableNode3: AKMixer
    var tappableNode4: AKMixer
    var tracker: AKPitchTap!
    var silence: AKBooster

    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    @Published var data = TunerData()

    let rollingPlot: AKNodeOutputPlot
    let bufferPlot: AKNodeOutputPlot
    let fftPlot: AKNodeFFTPlot

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

        for i in 0 ..< noteFrequencies.count {
            let distance = fabsf(Float(noteFrequencies[i]) - frequency)
            if distance < minDistance {
                index = i
                minDistance = distance
            }
        }
        let octave = Int(log2f(pitch / frequency))
        data.noteNameWithSharps = "\(noteNamesWithSharps[index])\(octave)"
        data.noteNameWithFlats = "\(noteNamesWithFlats[index])\(octave)"
    }

    init() {
        mic = engine.input
        tappableNode1 = AKMixer(mic)
        tappableNode2 = AKMixer(tappableNode1)
        tappableNode3 = AKMixer(tappableNode2)
        tappableNode4 = AKMixer(tappableNode3)
        silence = AKBooster(tappableNode4, gain: 0)
        engine.output = silence

        rollingPlot = AKNodeOutputPlot(tappableNode1)
        bufferPlot = AKNodeOutputPlot(tappableNode2)
        fftPlot = AKNodeFFTPlot(tappableNode3)

        tracker = AKPitchTap(tappableNode4) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }

    }

    func start() {
        AKSettings.audioInputEnabled = true

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
                        try AKEngine.setInputDevice(device)
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

