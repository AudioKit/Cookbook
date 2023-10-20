import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Speech
import SwiftUI
class CustomTap: BaseTap {
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var analyzer: SFSpeechRecognizer?
    var recognitionTask: SFSpeechRecognitionTask?

    func setupRecognition() {
        analyzer = SFSpeechRecognizer()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create recognition request") }
        recognitionRequest.shouldReportPartialResults = true
    }

    func stopRecognition() {
        recognitionRequest = nil
        recognitionTask = nil
    }

    override func doHandleTapBlock(buffer: AVAudioPCMBuffer, at _: AVAudioTime) {
        if let recognitionRequest = recognitionRequest {
            recognitionRequest.append(buffer)
        }
    }
}

class Conductor: ObservableObject {
    @Published var textString = ""
    let engine = AudioEngine()
    let myTap: CustomTap
    let mic: AudioEngine.InputNode?
    let outputMixer: Mixer
    let silencer: Fader
    init() {
        mic = engine.input
        outputMixer = Mixer(mic!)
        myTap = CustomTap(mic!, bufferSize: 4096, callbackQueue: .main)
        silencer = Fader(outputMixer, gain: 0)
        engine.output = silencer
        do {
            try engine.start()
        } catch {}
        myTap.start()
        myTap.setupRecognition()
        if let analyzer = myTap.analyzer {
            myTap.recognitionTask = analyzer.recognitionTask(with: myTap.recognitionRequest!) { result, err in
                var isFinal = false
                if let result = result {
                    isFinal = result.isFinal
                    self.textString = result.bestTranscription.formattedString
                }

                if err != nil || isFinal {
                    self.engine.stop()
                    self.myTap.stopRecognition()
                }
            }
        }
    }
}

struct BaseTapDemoView: View {
    @StateObject var conductor = Conductor()
    var body: some View {
        VStack {
            Text("Start talking...")
                .font(.title)
                .padding()
            Text(conductor.textString)
                .font(.title3)
                .padding()
            FFTView(conductor.outputMixer)
        }
        .padding()
        .cookbookNavBarTitle("BaseTap")
    }
}
