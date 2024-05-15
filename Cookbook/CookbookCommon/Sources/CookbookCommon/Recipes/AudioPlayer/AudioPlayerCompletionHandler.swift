import AudioKit
import AVFoundation
import SwiftUI

class CompletionHandlerConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var player = AudioPlayer()
    var fileURL = [URL]()
    @Published var playDuration = 0.0
    var currentFileIndex = 0

    // Load the files to play
    func getPlayerFiles() {
        let files = ["Bass Synth.mp3", "Piano.mp3",
                     "Synth.mp3", "Strings.mp3", "Guitar.mp3"]
        for filename in files {
            guard let url = Bundle.module.resourceURL?.appendingPathComponent(
                "Samples/\(filename)")
            else {
                Log("failed to load sample", filename)
                return
            }
            fileURL.append(url)
        }
    }

    /* Completion handler function:
     a function returning void */
    func playNextFile() {
        if currentFileIndex < 4 {
            currentFileIndex += 1
        } else {
            currentFileIndex = 0
        }
        startPlaying()
    }

    init() {
        getPlayerFiles()
        engine.output = player

        /* Assign the function
         to the completion handler */
        player.completionHandler = playNextFile
    }

    func startPlaying() {
        try? player.load(url: fileURL[currentFileIndex])
        player.play()
        if let duration = player.file?.duration {
            playDuration = duration
        }
    }

}

struct AudioPlayerCompletionHandler: View {
    @StateObject var conductor = CompletionHandlerConductor()

    var body: some View {
        Text("AudioPlayer Completion Handler")
            .padding()
        Text("This will play one file. Once it completes, it will play another.")
        Text("That's one thing a completion handler can do.")
        VStack {
            let playLabel = "Playing: " + conductor.fileURL[conductor.currentFileIndex]
                .deletingPathExtension().lastPathComponent
            let playTimeRange = Date()...Date().addingTimeInterval(conductor.playDuration)
            ProgressView(timerInterval: playTimeRange, countsDown: false) {
                Text(playLabel)
            }
        }
        .onAppear {
            conductor.start()
            conductor.startPlaying()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
