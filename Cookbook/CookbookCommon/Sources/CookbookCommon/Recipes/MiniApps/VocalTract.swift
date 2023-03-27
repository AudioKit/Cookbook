import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import Combine
import SoundpipeAudioKit
import SwiftUI

class VocalTractConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()

    @Published var isPlaying: Bool = false {
        didSet { isPlaying ? voc.start() : voc.stop() }
    }

    var voc = VocalTract()

    init() {
        engine.output = voc
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
            Text(conductor.isPlaying ? "STOP" : "START")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isPlaying.toggle()
            }

            Button2(text: "Randomize") {
                conductor.voc.frequency = AUValue.random(in: 0 ... 2000)
                conductor.voc.tonguePosition = AUValue.random(in: 0 ... 1)
                conductor.voc.tongueDiameter = AUValue.random(in: 0 ... 1)
                conductor.voc.tenseness = AUValue.random(in: 0 ... 1)
                conductor.voc.nasality = AUValue.random(in: 0 ... 1)
            }

            HStack {
                ForEach(conductor.voc.parameters) {
                    ParameterRow(param: $0)
                }
            }.frame(height: 150)
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
