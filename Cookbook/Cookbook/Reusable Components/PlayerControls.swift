import AudioKit
import SwiftUI

protocol ProcessesPlayerInput {
    var player: AudioPlayer { get }
}

struct PlayerControls: View {
    var conductor: ProcessesPlayerInput
    @State var isPlaying = false

    var body: some View {
        HStack {
            Text("Playback: ")
            Image(systemName: isPlaying ? "stop" : "play" ).onTapGesture {
                self.isPlaying ? self.conductor.player.pause() : self.conductor.player.play()
                self.isPlaying.toggle()
            }
        }
    }
}
