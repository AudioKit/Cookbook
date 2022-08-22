import AudioKit
import AVFoundation
import SwiftUI

class CompletionHandlerConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var player = AudioPlayer()
    var fileURL = [URL]()
    var currentTime = 0.0
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
        try? player.load(url: fileURL[0])
    }

    /* Completion handler function:
     a function returning void */
    func playNextFile() {
        currentTime = 0.0
        if currentFileIndex < 4 {
            currentFileIndex += 1
            try? player.load(url: fileURL[currentFileIndex])
            player.play()
        } else {
            currentFileIndex = 0
            try? player.load(url: fileURL[currentFileIndex])
            player.play()
        }
    }

    init() {
        getPlayerFiles()
        engine.output = player

        /* Assign the function
         to the completion handler */
        player.completionHandler = playNextFile
    }

    // Player functions
    func loadFile(url: URL) {
        do {
            try player.load(url: url)
        } catch {
            Log(error.localizedDescription, type: .error)
        }
    }
}

struct AudioPlayerCompletionHandler: View {
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var currentPlayTime = 0.0
    @State var playDuration = 0.0
    @State var playLabel = ""
    @StateObject var conductor = CompletionHandlerConductor()
    var body: some View {
        Text("AudioPlayer Completion Handler")
            .padding()
        Text("This will play one file. Once it completes, it will play another!")
        Text("That's one thing a completion handler can do!")
        VStack {
            ProgressView(playLabel, value: currentPlayTime, total: playDuration)
        }
        .onAppear {
            conductor.start()
            conductor.player.play()
        }
        .onDisappear {
            conductor.stop()
        }
        .onReceive(timer) { _ in
            currentPlayTime = conductor.currentTime
            if let duration = conductor.player.file?.duration {
                playDuration = duration
            }
            if currentPlayTime < playDuration {
                conductor.currentTime += 0.01
            } else {
                currentPlayTime = 0.0
                conductor.currentTime = 0.0
            }
            playLabel = "Playing: " + conductor.fileURL[conductor.currentFileIndex]
                .deletingPathExtension().lastPathComponent
        }
    }
}
