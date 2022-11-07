import AudioKit
import SwiftUI
import UniformTypeIdentifiers

class PlaylistConductor: ObservableObject, ProcessesPlayerInput {
    struct AudioFile: Identifiable, Hashable {
        let id = UUID()
        let url: URL
        let name: String
    }

    let supportedAudioFormats = [
        "aac", "adts", "ac3", "aif",
        "aiff", "aifc", "caf", "mp3",
        "mp4", "m4a", "snd", "au", "sd2",
        "wav",
    ]

    let engine = AudioEngine()
    let player = AudioPlayer()

    /// An array of audio files that comprises our playlist.
    var audioFiles = [AudioFile]()

    /// The audio file that is currently playing. Its value is set  to `nil` when the playback ends.
    /// For a player with more features you may want to track the player state separately.
    @Published var loadedFile: AudioFile?

    init() {
        engine.output = player
        player.completionHandler = playbackCompletionHandler
    }

    /// Empties our 'audioFiles' array before populating it with all supported files from the provided folder.
    func getAudioFiles(in folderURL: URL) {
        audioFiles = []
        let fileManager = FileManager.default

        do {
            let urls = try fileManager.contentsOfDirectory(at: folderURL,
                                                            includingPropertiesForKeys: nil)
            for url in urls {
                if supportedAudioFormats.contains(url.pathExtension) {
                    audioFiles.append(
                        AudioFile(
                            url: url,
                            name: url.deletingPathExtension().lastPathComponent
                        )
                    )
                }
            }
        } catch {
            Log(error.localizedDescription, type: .error)
        }
    }

    /// Tries to play the given audio file if there is no file currently playing. If there is a
    /// file playing it will stop the playback.
    func togglePlayback(of audioFile: AudioFile) {
        if loadedFile == nil {
            do {
                try player.load(url: audioFile.url)
                player.play()
                loadedFile = audioFile
            } catch {
                Log(error.localizedDescription, type: .error)
            }
        } else {
            player.stop()
            loadedFile = nil
        }
    }

    /// Sets 'loadedFile' to `nil` when an audio file finishes playing. It is a callback
    /// assigned to the 'completionHandler' property of our player instance.
    private func playbackCompletionHandler() {
        loadedFile = nil
    }
}

struct PlaylistView: View {
    @StateObject var conductor = PlaylistConductor()
    @State var showingFileImporter = false
    @State var folderURL = URL(fileURLWithPath: "")

    var body: some View {
        VStack(spacing: 25) {
            // Button to let user select the folder for their playlist
            Button("Select Playlist Folder") {
                showingFileImporter = true
            }

            Text("Click on file below to play...")

            // View with audio files contained in the selected folder (makes a playlist)
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(conductor.audioFiles, id: \.self) { audioFile in
                        Button {
                            conductor.togglePlayback(of: audioFile)
                        } label: {
                            HStack {
                                Text(audioFile.name)
                                Spacer()
                                if conductor.loadedFile == audioFile {
                                    Image(systemName: "play")
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Start the audio engine when the view appears
            conductor.start()
        }
        .onDisappear {
            // Stop the audio engine when the view disappears
            conductor.stop()
            folderURL.stopAccessingSecurityScopedResource()
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.folder]) { res in
            // Get the files in user-selected folder when $openFile is true
            do {
                folderURL = try res.get()
                if folderURL.startAccessingSecurityScopedResource() {
                    conductor.getAudioFiles(in: folderURL)
                } else {
                    Log("Couldn't load folder", type: .error)
                }
            } catch {
                Log(error.localizedDescription, type: .error)
            }
        }
    }
}
