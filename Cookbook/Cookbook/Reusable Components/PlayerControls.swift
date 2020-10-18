import AudioKit
import AVFoundation
import SwiftUI

protocol ProcessesPlayerInput {
    var player: AudioPlayer { get }
}

struct PlayerControls: View {
    @Environment(\.colorScheme) var colorScheme
    
    var conductor: ProcessesPlayerInput
    
    let sources: [[String]] = [
        ["Drums", "beat.aiff"],
        ["Speech", "alphabet.mp3"]
    ]
    
    @State var isPlaying = false
    @State var sourceName = "Drums"

    var body: some View {
        HStack {
            Menu("Source Audio") {
                ForEach(sources, id: \.self) { source in
                    Button(action: {
                        load(filename: source[1])
                        sourceName = source[0]
                    }) {
                        HStack {
                            Text(source[0])
                            Spacer()
                            if sourceName == source[0] {
                                Image(systemName: isPlaying ? "speaker.3.fill" : "speaker.fill")
                            }
                        }
                    }
                }
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.blue, .accentColor]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .cornerRadius(20.0)
            .shadow(color: ColorManager.accentColor.opacity(0.4), radius: 5, x: 0.0, y: 3)
            Button(action: {
                self.isPlaying ? self.conductor.player.pause() : self.conductor.player.play()
                self.isPlaying.toggle()
            }, label: {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill" )
            })
            .padding()
            .background(isPlaying ? Color.red : Color.green)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .cornerRadius(20.0)
            .shadow(color: ColorManager.accentColor.opacity(0.4), radius: 5, x: 0.0, y: 3)
        }
        .padding(.vertical, 15)
    }
    
    func load(filename: String) {
        conductor.player.stop()
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/\(filename)")
        let file = try! AVAudioFile(forReading: url!)
        let buffer = try! AVAudioPCMBuffer(file: file)!
        conductor.player.scheduleBuffer(buffer, at: nil, options: .loops)
        if isPlaying {
            conductor.player.play()
        }
    }
}
