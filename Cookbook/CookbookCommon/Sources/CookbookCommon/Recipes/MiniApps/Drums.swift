// Copyright AudioKit. All Rights Reserved.

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Combine
import SwiftUI

struct DrumSample {
    var name: String
    var fileName: String
    var midiNote: Int
    var audioFile: AVAudioFile?
    var color = UIColor.red

    init(_ prettyName: String, file: String, note: Int) {
        name = prettyName
        fileName = file
        midiNote = note

        guard let url = Bundle.module.resourceURL?.appendingPathComponent(file) else { return }
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            Log("Could not load: \(fileName)")
        }
    }
}

class DrumsConductor: ObservableObject, HasAudioEngine {
    // Mark Published so View updates label on changes
    @Published private(set) var lastPlayed: String = "None"

    let engine = AudioEngine()

    let drumSamples: [DrumSample] =
        [
            DrumSample("OPEN HI HAT", file: "Samples/open_hi_hat_A#1.wav", note: 34),
            DrumSample("HI TOM", file: "Samples/hi_tom_D2.wav", note: 38),
            DrumSample("MID TOM", file: "Samples/mid_tom_B1.wav", note: 35),
            DrumSample("LO TOM", file: "Samples/lo_tom_F1.wav", note: 29),
            DrumSample("HI HAT", file: "Samples/closed_hi_hat_F#1.wav", note: 30),
            DrumSample("CLAP", file: "Samples/clap_D#1.wav", note: 27),
            DrumSample("SNARE", file: "Samples/snare_D1.wav", note: 26),
            DrumSample("KICK", file: "Samples/bass_drum_C1.wav", note: 24),
        ]

    let drums = AppleSampler()

    func playPad(padNumber: Int) {
        drums.play(noteNumber: MIDINoteNumber(drumSamples[padNumber].midiNote))
        let fileName = drumSamples[padNumber].fileName
        lastPlayed = fileName.components(separatedBy: "/").last!
    }

    init() {
        engine.output = drums
        do {
            let files = drumSamples.map {
                $0.audioFile!
            }
            try drums.loadAudioFiles(files)

        } catch {
            Log("Files Didn't Load")
        }
    }
}

struct PadsView: View {
    var conductor: DrumsConductor

    var padsAction: (_ padNumber: Int) -> Void
    @State var downPads: [Int] = []

    var body: some View {
        VStack(spacing: 10) {
            NodeOutputView(conductor.drums)
            ForEach(0 ..< 2, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0 ..< 4, id: \.self) { column in
                        ZStack {
                            Rectangle()
                                .fill(Color(conductor.drumSamples.map { downPads.contains(where: { $0 == row * 4 + column }) ? .gray : $0.color }[getPadId(row: row, column: column)]))
                                .cornerRadius(20)
                            Text(conductor.drumSamples.map { $0.name }[getPadId(row: row, column: column)])
                                .foregroundColor(Color(.white)).fontWeight(.bold)
                        }
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { _ in
                            if !(downPads.contains(where: { $0 == row * 4 + column })) {
                                padsAction(getPadId(row: row, column: column))
                                downPads.append(row * 4 + column)
                            }
                        }.onEnded { _ in
                            downPads.removeAll(where: { $0 == row * 4 + column })
                        })
                    }
                }.padding(5)
            }
        }
        .cookbookNavBarTitle("Drum Pads")
    }
}

struct DrumsView: View {
    @StateObject var conductor = DrumsConductor()

    var body: some View {
        VStack(spacing: 2) {
            PadsView(conductor: conductor) { pad in
                conductor.playPad(padNumber: pad)
            }
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}

private func getPadId(row: Int, column: Int) -> Int {
    return (row * 4) + column
}
