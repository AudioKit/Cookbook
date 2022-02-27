import AudioKit
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

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct ReverbView: View {
    var conductor = ReverbConductor()

    var body: some View {
        VStack(spacing: 20) {
            PlayerControls(conductor: conductor)
            HStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("Cathedral").onTapGesture { conductor.reverb.loadFactoryPreset(.cathedral) }
                    Text("Large Hall").onTapGesture { conductor.reverb.loadFactoryPreset(.largeHall) }
                    Text("Large Hall 2").onTapGesture { conductor.reverb.loadFactoryPreset(.largeHall2) }
                    Text("Large Room").onTapGesture { conductor.reverb.loadFactoryPreset(.largeRoom) }
                    Text("Large Room 2").onTapGesture { conductor.reverb.loadFactoryPreset(.largeRoom2) }
                    Text("Medium Chamber").onTapGesture { conductor.reverb.loadFactoryPreset(.mediumChamber) }
                }
                VStack(spacing: 20) {
                    Text("Medium Hall").onTapGesture { conductor.reverb.loadFactoryPreset(.mediumHall) }
                    Text("Medium Hall 2").onTapGesture { conductor.reverb.loadFactoryPreset(.mediumHall2) }
                    Text("Medium Hall 3").onTapGesture { conductor.reverb.loadFactoryPreset(.mediumHall3) }
                    Text("Medium Room").onTapGesture { conductor.reverb.loadFactoryPreset(.mediumRoom) }
                    Text("Plate").onTapGesture { conductor.reverb.loadFactoryPreset(.plate) }
                    Text("Small Room").onTapGesture { conductor.reverb.loadFactoryPreset(.smallRoom) }
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text("Apple Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Reverb_Previews: PreviewProvider {
    static var previews: some View {
        ReverbView()
    }
}
