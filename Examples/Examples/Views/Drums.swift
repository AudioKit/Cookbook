// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import Combine
import SwiftUI

struct DrumSample {
    var name: String
    var fileName: String
    var midiNote: Int
    var audioFile: AVAudioFile?
    var color = AKStylist.sharedInstance.nextColor

    init(_ prettyName: String, file: String, note: Int) {
        name = prettyName
        fileName = file
        midiNote = note

        guard let url = Bundle.main.resourceURL?.appendingPathComponent(file) else { return }
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            AKLog("Could not load: $fileName")
        }
    }
}

class DrumsConductor: ObservableObject {
    // Mark Published so View updates label on changes
    @Published private(set) var lastPlayed: String = "None"

    let drumSamples: [DrumSample] =
        [
            DrumSample("OPEN HI HAT", file: "Samples/open_hi_hat_A#1.wav", note: 34),
            DrumSample("HI TOM", file: "Samples/hi_tom_D2.wav", note: 38),
            DrumSample("MID TOM", file: "Samples/mid_tom_B1.wav", note: 35),
            DrumSample("LO TOM", file: "Samples/lo_tom_F1.wav", note: 29),
            DrumSample("HI HAT", file: "Samples/closed_hi_hat_F#1.wav", note: 30),
            DrumSample("CLAP", file: "Samples/clap_D#1.wav", note: 27),
            DrumSample("SNARE", file: "Samples/snare_D1.wav", note: 26),
            DrumSample("KICK", file: "Samples/bass_drum_C1.wav", note: 24)
        ]

    let drums = AKAppleSampler()

    func playPad(padNumber: Int) {
        try? drums.play(noteNumber: MIDINoteNumber(drumSamples[padNumber].midiNote))
        let fileName = drumSamples[padNumber].fileName
        lastPlayed = fileName.components(separatedBy: "/").last!
    }

    func start() {
        AKManager.output = drums
        do {
            try AKManager.start()
        } catch {
            AKLog("AudioKit did not start! \(error)")
        }
        do {
            let files = drumSamples.map {
                $0.audioFile!
            }
            try drums.loadAudioFiles(files)

        } catch {
            AKLog("Files Didn't Load")
        }
    }
}

struct PadsView: View {
    @EnvironmentObject var conductor: DrumsConductor

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
                                    .fill(Color(self.conductor.drumSamples.map({ $0.color })[getPadId(row: row, column: column)]))
                                Text(self.conductor.drumSamples.map({ $0.name })[getPadId(row: row, column: column)])
                                    .foregroundColor(Color("FontColor")).fontWeight(.bold)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Drums"))
        .onAppear {
            // Important to start AudioKit after the app has moved to the foreground on Catalyst
            self.conductor.start()
        }
    }
}

struct DrumsView: View {
    @EnvironmentObject var conductor: DrumsConductor

    var body: some View {
        VStack(spacing: 2) {
            PadsView { pad in
                self.conductor.playPad(padNumber: pad)
            }
            Spacer().fixedSize().frame(minWidth: 0, maxWidth: .infinity,
                                       minHeight: 0, maxHeight: 5, alignment: .topLeading)
        }
    }
}

private func getPadId(row: Int, column: Int) -> Int {
    return (row * 4) + column
}

struct DrumsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
