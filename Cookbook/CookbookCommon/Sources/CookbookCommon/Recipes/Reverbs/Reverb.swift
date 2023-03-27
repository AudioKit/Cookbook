import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

class ReverbConductor: ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer
    let reverb: Reverb

    init() {
        buffer = Cookbook.sourceBuffer
        player.buffer = buffer
        player.isLooping = true

        reverb = Reverb(player)
        reverb.dryWetMix = 50
        engine.output = reverb
    }
}

struct ReverbView: View {
    var conductor = ReverbConductor()

    var body: some View {
        VStack(spacing: 20) {
            PlayerControls(conductor: conductor)
            HStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("Cathedral")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.cathedral) }
                    Text("Large Hall")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.largeHall) }
                    Text("Large Hall 2")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.largeHall2) }
                    Text("Large Room")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.largeRoom) }
                    Text("Large Room 2")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.largeRoom2) }
                    Text("Medium Chamber")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.mediumChamber) }
                }
                VStack(spacing: 20) {
                    Text("Medium Hall")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.mediumHall) }
                    Text("Medium Hall 2")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.mediumHall2) }
                    Text("Medium Hall 3")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.mediumHall3) }
                    Text("Medium Room")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.mediumRoom) }
                    Text("Plate")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.plate) }
                    Text("Small Room")
                        .foregroundColor(.blue)
                        .onTapGesture { conductor.reverb.loadFactoryPreset(.smallRoom) }
                }
            }
            Spacer()
        }
        .padding()
        .cookbookNavBarTitle("Apple Reverb")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
