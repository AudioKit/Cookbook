// Copyright AudioKit. All Rights Reserved.

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import Combine
import SwiftUI

class DrumSequencerConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    let drums = MIDISampler(name: "Drums")
    var midiCallback = MIDICallbackInstrument()
    let sequencer = AppleSequencer(fromURL: Bundle.module.url(forResource: "MIDI Files/4tracks", withExtension: "mid")!)

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

    func randomize() {
        sequencer.tracks[2].clearRange(start: Duration(beats: 0), duration: Duration(beats: 4))
        for i in 0 ... 15 {
            sequencer.tracks[2].add(
                noteNumber: MIDINoteNumber(30 + Int(AUValue.random(in: 0 ... 1.99))),
                velocity: MIDIVelocity(AUValue.random(in: 80 ... 127)),
                position: Duration(beats: Double(i) / 4.0),
                duration: Duration(beats: 0.5)
            )
        }
    }

    init() {
        midiCallback.callback = { status, note, velocity in
            if status == 144 { // Note On
                self.drums.play(noteNumber: note, velocity: velocity, channel: 0)
            } else if status == 128 { // Note Off

            }
        }
        engine.output = drums
        do {
            let bassDrumURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/bass_drum_C1.wav")
            let bassDrumFile = try AVAudioFile(forReading: bassDrumURL!)
            let clapURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/clap_D#1.wav")
            let clapFile = try AVAudioFile(forReading: clapURL!)
            let closedHiHatURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/closed_hi_hat_F#1.wav")
            let closedHiHatFile = try AVAudioFile(forReading: closedHiHatURL!)
            let hiTomURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/hi_tom_D2.wav")
            let hiTomFile = try AVAudioFile(forReading: hiTomURL!)
            let loTomURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/lo_tom_F1.wav")
            let loTomFile = try AVAudioFile(forReading: loTomURL!)
            let midTomURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/mid_tom_B1.wav")
            let midTomFile = try AVAudioFile(forReading: midTomURL!)
            let openHiHatURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/open_hi_hat_A#1.wav")
            let openHiHatFile = try AVAudioFile(forReading: openHiHatURL!)
            let snareDrumURL = Bundle.module.resourceURL?.appendingPathComponent("Samples/snare_D1.wav")
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
        sequencer.setGlobalMIDIOutput(midiCallback.midiIn)
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
                duration: Duration(beats: 0.5)
            )
        }

        sequencer.tracks[3].add(noteNumber: 26, velocity: 127, position: Duration(beats: 2), duration: Duration(beats: 1))
    }
}

struct DrumSequencerView: View {
    @StateObject var conductor = DrumSequencerConductor()

    var body: some View {
        VStack(spacing: 10) {
            Text(conductor.isPlaying ? "Stop" : "Start")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.isPlaying.toggle()
            }
            Text("Randomize Hi-hats")
                .foregroundColor(.blue)
                .onTapGesture {
                conductor.randomize()
            }
            CookbookKnob(text: "Tempo",
                            parameter: $conductor.tempo,
                            range: 60 ... 300).padding(5)
            NodeOutputView(conductor.drums)
            Spacer()
        }
        .cookbookNavBarTitle("Drum Sequencer")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.isPlaying = false
            conductor.drums.destroyEndpoint()
            conductor.stop()
        }
    }
}
