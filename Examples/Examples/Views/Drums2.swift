// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKit
import Combine
import SwiftUI

class Drums2Conductor: ObservableObject {
    // Mark Published so View updates label on changes
    @Published private(set) var lastPlayed: String = "None"

    let engine = AudioEngine()

    let file = try! AVAudioFile(forReading: Bundle.main.url(forResource: "Samples/open_hi_hat_A#1", withExtension: "wav")!)

    let drums: Sampler

    init() {
        drums = Sampler(sampleDescriptor: SampleDescriptor(noteNumber: 64, noteFrequency: 440, minimumNoteNumber: 1, maximumNoteNumber: 80, minimumVelocity: 0, maximumVelocity: 127, isLooping: false, loopStartPoint: 0, loopEndPoint: 1.0, startPoint: 0, endPoint: 1) , file: file)
    }

    func playPad(padNumber: Int) {
        drums.play(noteNumber: MIDINoteNumber(64), velocity: 100)
    }

    func start() {
        engine.output = drums
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start! \(error)")
        }
    }

    func stop() {
        engine.stop()
    }
}

struct Pads2View: View {
    var conductor: Drums2Conductor

    var padsAction: (_ padNumber: Int) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { column in
                        Button(action: {
                            self.padsAction(getPadId(row: row, column: column))
                        }) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.red)
                                Text("A")
                                    .foregroundColor(Color("FontColor")).fontWeight(.bold)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Drums"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Drums2View: View {
    @ObservedObject var conductor = Drums2Conductor()

    var body: some View {
        VStack(spacing: 2) {
            Pads2View(conductor: conductor) { pad in
                self.conductor.playPad(padNumber: pad)
            }
            Spacer().fixedSize().frame(minWidth: 0, maxWidth: .infinity,
                                       minHeight: 0, maxHeight: 5, alignment: .topLeading)
        }
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

private func getPadId(row: Int, column: Int) -> Int {
    return (row * 4) + column
}

struct Drums2View_Previews: PreviewProvider {
    static var previews: some View {
        DrumsView()
    }
}
