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
            Button(action: {
                self.isPlaying ? self.conductor.player.pause() : self.conductor.player.play()
                self.isPlaying.toggle()
            }, label: {
                Text("Playback ")
                    .fontWeight(.bold)
                    .font(.system(.callout, design: .rounded))
                Image(systemName: isPlaying ? "stop.fill" : "play.fill" )
            })
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.blue, ColorManager.accentColor]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .cornerRadius(20.0)
            .shadow(color: ColorManager.accentColor.opacity(0.4), radius: 5, x: 0.0, y: 3)
        }
        .padding(.vertical, 15)
    }
}
