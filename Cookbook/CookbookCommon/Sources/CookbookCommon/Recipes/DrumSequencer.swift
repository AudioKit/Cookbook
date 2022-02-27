// Copyright AudioKit. All Rights Reserved.

import AudioKit
import AudioKitUI
import AVFoundation
import Combine
import SwiftUI

class DrumSequencerConductor: ObservableObject {
    let engine = AudioEngine()
    let drums = MIDISampler(name: "Drums")
    let sequencer = AppleSequencer(filename: "4tracks")

    @Published var tempo: Float = 120 {
        didSet {
            sequencer.setTempo(BPM(tempo))
        }
    }
    @Published var isPlaying = false {
        didSet {
            isPlaying ? sequencer.play() : sequencer.stop()
        }
    }

    init() {
        engine.output = drums
    }

    func randomize() {
        sequencer.tracks[2].clearRange(start: Duration(beats: 0), duration: Duration(beats: 4))
        for i in 0 ... 15 {
            sequencer.tracks[2].add(
                noteNumber: MIDINoteNumber(30 + Int(AUValue.random(in: 0 ... 1.99))),
                velocity: MIDIVelocity(AUValue.random(in: 80 ... 127)),
                position: Duration(beats: Double(i) / 4.0),
                duration: Duration(beats: 0.5))
        }
    }

    func start() {
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start! \(error)")
        }
        do {
            let bassDrumURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/bass_drum_C1.wav")
            let bassDrumFile = try AVAudioFile(forReading: bassDrumURL!)
            let clapURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/clap_D#1.wav")
            let clapFile = try AVAudioFile(forReading: clapURL!)
            let closedHiHatURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/closed_hi_hat_F#1.wav")
            let closedHiHatFile = try AVAudioFile(forReading: closedHiHatURL!)
            let hiTomURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/hi_tom_D2.wav")
            let hiTomFile = try AVAudioFile(forReading: hiTomURL!)
            let loTomURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/lo_tom_F1.wav")
            let loTomFile = try AVAudioFile(forReading: loTomURL!)
            let midTomURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/mid_tom_B1.wav")
            let midTomFile = try AVAudioFile(forReading: midTomURL!)
            let openHiHatURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/open_hi_hat_A#1.wav")
            let openHiHatFile = try AVAudioFile(forReading: openHiHatURL!)
            let snareDrumURL = Bundle.main.resourceURL?.appendingPathComponent("Samples/snare_D1.wav")
            let snareDrumFile = try AVAudioFile(forReading: snareDrumURL!)

            try drums.loadAudioFiles([bassDrumFile,
                                      clapFile,
                                      closedHiHatFile,
                                      hiTomFile,
                                      loTomFile,
                                      midTomFile,
                                      openHiHatFile,
                                      snareDrumFile])

        } catch {
            Log("Files Didn't Load")
        }
        sequencer.clearRange(start: Duration(beats: 0), duration: Duration(beats: 100))
        sequencer.debug()
        sequencer.setGlobalMIDIOutput(drums.midiIn)
        sequencer.enableLooping(Duration(beats: 4))
        sequencer.setTempo(150)

        sequencer.tracks[0].add(noteNumber: 24, velocity: 80, position: Duration(beats: 0), duration: Duration(beats: 1))

        sequencer.tracks[0].add(noteNumber: 24, velocity: 80, position: Duration(beats: 2), duration: Duration(beats: 1))

        sequencer.tracks[1].add(noteNumber: 26, velocity: 80, position: Duration(beats: 2), duration: Duration(beats: 1))

        for i in 0 ... 7 {
            sequencer.tracks[2].add(
                noteNumber: 30,
                velocity: 127,
                position: Duration(beats: Double(i) / 2.0),
                duration: Duration(beats: 0.5))
        }

        sequencer.tracks[3].add(noteNumber: 26, velocity: 127, position: Duration(beats: 2), duration: Duration(beats: 1))
    }

    func stop() {
        engine.stop()
    }
}

struct DrumSequencerView: View {
    @StateObject var conductor = DrumSequencerConductor()

    var body: some View {
        VStack(spacing: 10) {
            Text(conductor.isPlaying ? "Stop" : "Play").onTapGesture {
                conductor.isPlaying.toggle()
            }
            Text("Randomize Hi-hats").onTapGesture {
                conductor.randomize()
            }
            ParameterSlider(text: "Tempo",
                            parameter: self.$conductor.tempo,
                            range: 60 ... 300).padding(5).frame(height: 100)
            NodeOutputView(conductor.drums)
            Spacer()
        }
        .navigationBarTitle(Text("Drum Sequencer"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct DrumSequencerView_Previews: PreviewProvider {
    static var previews: some View {
        DrumSequencerView()
    }
}
