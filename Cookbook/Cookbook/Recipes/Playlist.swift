import SwiftUI
import AudioKit
import UniformTypeIdentifiers

struct PlayerFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
}
struct PlayerFileItem: View {
    var playerFile: PlayerFile
    var body: some View {
        Text(playerFile.name)
    }
}
class PlaylistConductor: ObservableObject {
    let engine = AudioEngine()
    var audioFileList = [PlayerFile]()
    var player = AudioPlayer()

    init() {
        engine.output = player
    }

    // Find all the audio files in a user-selected folder
    func getPlayableFolderFiles(inFolderURL: URL) {
        do {
            let fileManager = FileManager.default
            let items = try fileManager.contentsOfDirectory(at: inFolderURL,
                                                            includingPropertiesForKeys: nil)

            for item in items {
                do {
                    guard let typeID = try item.resourceValues(forKeys:
                                                                [.typeIdentifierKey]).typeIdentifier
                    else { return }

                    guard let supertypes = UTType(typeID)?.supertypes
                    else { return }

                    if supertypes.contains(.audio) {
                        self.audioFileList.append(PlayerFile(url: item, name: item.deletingPathExtension().lastPathComponent))
                    }
                } catch {
                    Log(error.localizedDescription, type: .error)
                }
            }
        } catch {
            Log(error.localizedDescription, type: .error)
        }
    }

    // Player functions
    func loadFile(url: URL) {
        do {
            try player.load(url: url)
        } catch {
            Log(error.localizedDescription, type: .error)
        }
    }
    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }
    func stop() {
        engine.stop()
    }
}
struct PlaylistView : View {
    @State var openFile = false
    @StateObject var conductor = PlaylistConductor()
    @State var fileName = ""

    var body: some View {
        VStack(spacing: 25) {
            // Button to let user select the folder for their playlist
            Button(action: {openFile.toggle()},
                   label: {
                Text("Select Playlist Folder")
            })

            Text("Click on file below to play...")

            // View with audio files contained in the selected folder (makes a playlist)
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(conductor.audioFileList, id: \.self) { audioFile in
                        Button(action: {
                            try? conductor.player.load(url: audioFile.url)
                            fileName = audioFile.name
                            conductor.player.play()
                        }) {
                            HStack {
                                Text(audioFile.name)
                                Spacer()
                                if fileName == audioFile.name {
                                    Image(systemName: "play")
                                }
                            }.padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            // Start the audio engine when the view appears
            conductor.start()
        }
        .onDisappear {
            // Stop the audio engine when the view disappears
            conductor.stop()
        }
        .fileImporter(isPresented: $openFile,
                      allowedContentTypes: [.folder])
        { res in
            // Get the files in user-selected folder when $openFile is true
            do {
                let folderURL = try res.get()
                self.conductor.getPlayableFolderFiles(inFolderURL: folderURL)
            } catch {
                Log(error.localizedDescription, type: .error)
            }
        }
    }
}
