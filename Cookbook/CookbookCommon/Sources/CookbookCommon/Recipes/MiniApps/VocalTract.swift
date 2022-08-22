import AudioKit
import AudioKitUI
import AudioToolbox
import Combine
import SoundpipeAudioKit
import SwiftUI

struct VocalTractData {
    var isPlaying: Bool = false
    var frequency: AUValue = 220.0
    var tonguePosition: AUValue = 0.0
    var tongueDiameter: AUValue = 0.0
    var tenseness: AUValue = 0.0
    var nasality: AUValue = 0.0
    var rampDuration: AUValue = 0.0
}

class VocalTractConductor: ObservableObject {
    let engine = AudioEngine()

    @Published var data = VocalTractData() {
        didSet {
            if data.isPlaying {
                voc.start()
                voc.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
                voc.$tonguePosition.ramp(to: data.tonguePosition, duration: data.rampDuration)
                voc.$tongueDiameter.ramp(to: data.tongueDiameter, duration: data.rampDuration)
                voc.$tenseness.ramp(to: data.tenseness, duration: data.rampDuration)
                voc.$nasality.ramp(to: data.nasality, duration: data.rampDuration)
            } else {
                voc.stop()
            }
        }
    }

    var voc = VocalTract()

    init() {
        engine.output = voc
    }

    func start() {
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        data.isPlaying = false
        voc.stop()
        engine.stop()
    }
}

struct Button2: View {
    var text: String
    var onTap: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).foregroundColor(.gray)
            Text(text).onTapGesture {
                self.onTap()
            }
        }
    }
}

struct VocalTractView: View {
    @StateObject var conductor = VocalTractConductor()

    var body: some View {
        VStack {
            Text(conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                conductor.data.isPlaying.toggle()
            }

            Button2(text: "Randomize") {
                conductor.data.frequency = AUValue.random(in: 0 ... 2000)
                conductor.data.tonguePosition = AUValue.random(in: 0 ... 1)
                conductor.data.tongueDiameter = AUValue.random(in: 0 ... 1)
                conductor.data.tenseness = AUValue.random(in: 0 ... 1)
                conductor.data.nasality = AUValue.random(in: 0 ... 1)
            }

            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0 ... 2000,
                            format: "%0.0f")
            ParameterSlider(text: "Tongue Position",
                            parameter: self.$conductor.data.tonguePosition,
                            range: 0 ... 1,
                            format: "%0.2f")
            ParameterSlider(text: "Tongue Diameter",
                            parameter: self.$conductor.data.tongueDiameter,
                            range: 0 ... 1,
                            format: "%0.2f")
            ParameterSlider(text: "Tenseness",
                            parameter: self.$conductor.data.tenseness,
                            range: 0 ... 1,
                            format: "%0.2f")
            ParameterSlider(text: "Nasality",
                            parameter: self.$conductor.data.nasality,
                            range: 0 ... 1,
                            format: "%0.2f")
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0 ... 10,
                            format: "%0.2f")
            NodeOutputView(conductor.voc)
        }.cookbookNavBarTitle("Vocal Tract")
            .padding()
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}
