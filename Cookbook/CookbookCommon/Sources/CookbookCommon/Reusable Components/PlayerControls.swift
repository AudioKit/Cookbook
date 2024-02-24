import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

struct PlayerControls: View {
    @Environment(\.colorScheme) var colorScheme

    var conductor: ProcessesPlayerInput

    let sources: [[String]] = [
        ["Bass Synth", "Bass Synth.mp3"],
        ["Drums", "beat.aiff"],
        ["Female Voice", "alphabet.mp3"],
        ["Guitar", "Guitar.mp3"],
        ["Male Voice", "Counting.mp3"],
        ["Piano", "Piano.mp3"],
        ["Strings", "Strings.mp3"],
        ["Synth", "Synth.mp3"],
    ]

    @State var isPlaying = false
    @State var sourceName = "Drums"
    @State var isShowingSources = false
    @State private var dragOver = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .accentColor]), startPoint: .top, endPoint: .bottom)
                    .cornerRadius(dragOver ? 15.0 : 25.0)
                    .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0.0, y: 3)

                HStack {
                    Image(systemName: dragOver ? "arrow.down.doc" : "music.note.list")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Text("Source Audio: \(sourceName)").foregroundColor(.white)
                        .font(.system(size: 14, weight: dragOver ? .heavy : .semibold, design: .rounded))
                }
                .padding()
            }.onTapGesture {
                isShowingSources.toggle()
            }.onDrop(of: [.audio], isTargeted: $dragOver, perform: { providers -> Bool in
                providers.first?.loadItem(forTypeIdentifier: UTType.audio.identifier, options: nil) {item, _ in
                    guard let url = item as? URL else { return }
                    DispatchQueue.main.sync {
                        load(url: url)
                        sourceName = url.deletingPathExtension().lastPathComponent
                    }
                }
                return true
            })

            Button(action: {
                self.isPlaying ? conductor.player.stop() : conductor.player.play()
                self.isPlaying.toggle()
            }, label: {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
            })
            .padding()
            .background(isPlaying ? Color.red : Color.green)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .cornerRadius(25.0)
            .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0.0, y: 3)
        }
        .frame(minWidth: 300, idealWidth: 350, maxWidth: 360, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
        .padding()
        .sheet(isPresented: $isShowingSources,
               onDismiss: { print("finished!") },
               content: { SourceAudioSheet(playerControls: self) })
    }

    func load(filename: String) {
        conductor.player.stop()

        Log(filename)

        guard let url = Bundle.module.resourceURL?.appendingPathComponent("Samples/\(filename)"),
              let buffer = try? AVAudioPCMBuffer(url: url)
        else {
            Log("failed to load sample", filename)
            return
        }
        conductor.player.file = try? AVAudioFile(forReading: url)
        conductor.player.isLooping = true
        conductor.player.buffer = buffer

        if isPlaying {
            conductor.player.play()
        }
    }

    func load(url: URL) {
        conductor.player.stop()
        Log(url)
        guard let buffer = try? AVAudioPCMBuffer(url: url) else {
            Log("failed to load sample", url.deletingPathExtension().lastPathComponent)
            return
        }
        conductor.player.file = try? AVAudioFile(forReading: url)
        conductor.player.isLooping = true
        conductor.player.buffer = buffer

        if isPlaying {
            conductor.player.play()
        }
    }
}

struct SourceAudioSheet: View {
    @Environment(\.presentationMode) var presentationMode

    var playerControls: PlayerControls
    @State var browseFiles = false
    @State var fileURL = URL(fileURLWithPath: "")

    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 20) {
                    ForEach(playerControls.sources, id: \.self) { source in
                        Button(action: {
                            playerControls.load(filename: source[1])
                            playerControls.sourceName = source[0]
                        }) {
                            HStack {
                                Text(source[0])
                                Spacer()
                                if playerControls.sourceName == source[0] {
                                    Image(systemName: playerControls.isPlaying ? "speaker.3.fill" : "speaker.fill")
                                }
                            }.padding()
                        }
                    }
                }
                Button(action: { browseFiles.toggle() },
                       label: {
                           Text("Select Custom File")
                       })
                       .fileImporter(isPresented: $browseFiles, allowedContentTypes: [.audio]) { res in
                           do {
                               fileURL = try res.get()
                               if fileURL.startAccessingSecurityScopedResource() {
                                   playerControls.load(url: fileURL)
                                   playerControls.sourceName = fileURL.deletingPathExtension().lastPathComponent
                               } else {
                                   Log("Couldn't load file URL", type: .error)
                               }
                           } catch {
                               Log(error.localizedDescription, type: .error)
                           }
                       }
            }
            .onDisappear {
                fileURL.stopAccessingSecurityScopedResource()
            }
            .padding(.vertical, 15)
            .navigationTitle("Source Audio")
            #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            #endif
        }
    }
}
