import AudioKit
import AVFoundation
import SwiftUI

struct RecorderData {
    var isRecording = false
    var isPlaying = false
}

class RecorderConductor: ObservableObject {

    let engine = AudioEngine()
    let recorder: NodeRecorder
    let player = AudioPlayer()
    let silencer: Fader
    let mixer = Mixer()

    @Published var data = RecorderData() {
        didSet {
            if data.isRecording {
                NodeRecorder.removeTempFiles()
                do {
                    try recorder.record()
                } catch let err {
                    print(err)
                }
            } else {
                recorder.stop()
            }

            if data.isPlaying {
                if let file = recorder.audioFile {
                    player.scheduleFile(file, at: nil)
                    player.play()
                }
            } else {
                player.stop()
            }
        }
    }

    init() {
        do {
            recorder = try NodeRecorder(node: engine.input)
        } catch let err {
            fatalError("\(err)")
        }
        silencer = Fader(engine.input, gain: 0)
        mixer.addInput(silencer)
        mixer.addInput(player)
        engine.output = mixer
    }
    func start() {
        do {
            try engine.start()
        } catch let err {
            print(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct RecorderView: View {
    @ObservedObject var conductor = RecorderConductor()

    var body: some View {
        VStack {
            Spacer()
            Text(conductor.data.isRecording ? "STOP RECORDING" : "RECORD").onTapGesture {
                self.conductor.data.isRecording.toggle()
            }
            Spacer()
            Text(conductor.data.isPlaying ? "STOP" : "PLAY").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            Spacer()
        }

        .padding()
        .navigationBarTitle(Text("Recorder"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
