import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

struct RecorderData {
    var isRecording = false
    var isPlaying = false
}

class RecorderConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var recorder: NodeRecorder?
    let player = AudioPlayer()
    var silencer: Fader?
    let mixer = Mixer()

    @Published var data = RecorderData() {
        didSet {
            if data.isRecording {
                do {
                    try recorder?.record()
                } catch let err {
                    print(err)
                }
            } else {
                recorder?.stop()
            }

            if data.isPlaying {
                if let file = recorder?.audioFile {
                    try? player.load(file: file)
                    player.play()
                }
            } else {
                player.stop()
            }
        }
    }

    init() {
        guard let input = engine.input else {
            fatalError()
        }

        do {
            recorder = try NodeRecorder(node: input)
        } catch let err {
            fatalError("\(err)")
        }
        let silencer = Fader(input, gain: 0)
        self.silencer = silencer
        mixer.addInput(silencer)
        mixer.addInput(player)
        engine.output = mixer
    }
}

struct RecorderView: View {
    @StateObject var conductor = RecorderConductor()

    var body: some View {
        VStack {
            Spacer()
            Text(conductor.data.isRecording ? "STOP RECORDING" : "RECORD")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.data.isRecording.toggle()
            }
            Spacer()
            Text(conductor.data.isPlaying ? "STOP" : "PLAY")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.data.isPlaying.toggle()
            }
            Spacer()
        }

        .padding()
        .cookbookNavBarTitle("Recorder")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
