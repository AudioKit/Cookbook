import AudioKit
import AVFoundation
import SwiftUI

struct RecorderData {
    var isRecording = false
    var isPlaying = false
}

class RecorderConductor: ObservableObject {

    let engine = AKEngine()
    let recorder: AKNodeRecorder
    let player = AKPlayer()
    let silencer: AKBooster
    let mixer = AKMixer()

    @Published var data = RecorderData() {
        didSet {
            if data.isRecording {
                AKNodeRecorder.removeTempFiles()
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
            recorder = try AKNodeRecorder(node: engine.input)
        } catch let err {
            fatalError("\(err)")
        }
        silencer = AKBooster(engine.input)
        silencer.gain = 0
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
