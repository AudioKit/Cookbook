import AudioKit
import AudioKitUI
import AudioToolbox
import SwiftUI
import Combine

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
                voc.frequency = data.frequency
                voc.tonguePosition = data.tonguePosition
                voc.tongueDiameter = data.tongueDiameter
                voc.tenseness = data.tenseness
                voc.nasality = data.nasality
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
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }

            Button2(text: "Randomize") {
                self.conductor.data.frequency = AUValue.random(in: 0...2000)
                self.conductor.data.tonguePosition = AUValue.random(in: 0...1)
                self.conductor.data.tongueDiameter = AUValue.random(in: 0...1)
                self.conductor.data.tenseness = AUValue.random(in: 0...1)
                self.conductor.data.nasality = AUValue.random(in: 0...1)
            }

            ParameterSlider(text: "Frequency",
                            parameter: self.$conductor.data.frequency,
                            range: 0...2000,
                            format: "%0.0f")
            ParameterSlider(text: "Tongue Position",
                            parameter: self.$conductor.data.tonguePosition,
                            range: 0...1,
                            format: "%0.2f")
            ParameterSlider(text: "Tongue Diameter",
                            parameter: self.$conductor.data.tongueDiameter,
                            range: 0...1,
                            format: "%0.2f")
            ParameterSlider(text: "Tenseness",
                            parameter: self.$conductor.data.tenseness,
                            range: 0...1,
                            format: "%0.2f")
            ParameterSlider(text: "Nasality",
                            parameter: self.$conductor.data.nasality,
                            range: 0...1,
                            format: "%0.2f")
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...10,
                            format: "%0.2f")
            NodeOutputView(conductor.voc)
        }.navigationBarTitle(Text("Vocal Tract"))
        .padding()
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct VocalTractView_Previews: PreviewProvider {
    static var previews: some View {
        VocalTractView()
    }
}
