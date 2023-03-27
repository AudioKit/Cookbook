import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SoundpipeAudioKit
import SwiftUI

enum Synthesizer {
    case arpeggio, pad, bass
}

enum Instrument {
    case arpeggio, pad, bass, drum
}

enum Sound {
    case square, saw, pad, noisy
}

struct MusicToyData {
    var isPlaying: Bool = false
    var bassSound: Sound = .square
    var padSound: Sound = .square
    var arpeggioSound: Sound = .square
    var synthesizer: Synthesizer = .arpeggio
    var instrument: Instrument = .arpeggio
    var tempo: Float = 120
    var arpeggioVolume: Float = 0.8
    var padVolume: Float = 0.8
    var bassVolume: Float = 0.8
    var drumVolume: Float = 0.8
    var filterFrequency: Float = 1.0
    var length: Int = 4
}

class MusicToyConductor: ObservableObject, HasAudioEngine {
    var engine = AudioEngine()
    private var sequencer: AppleSequencer!
    private var mixer = Mixer()
    private var arpeggioSynthesizer = MIDISampler(name: "Arpeggio Synth")
    private var padSynthesizer = MIDISampler(name: "Pad Synth")
    private var bassSynthesizer = MIDISampler(name: "Bass Synth")
    private var drumKit = MIDISampler(name: "Drums")
    private var filter: MoogLadder?

    private var bassSound: Sound = .square
    private var padSound: Sound = .square
    private var arpeggioSound: Sound = .square
    private var length = 4

    @Published var data = MusicToyData() {
        didSet {
            data.isPlaying ? sequencer.play() : sequencer.stop()
            adjustTempo(data.tempo)
            if arpeggioSound != data.arpeggioSound {
                useSound(data.arpeggioSound, synthesizer: .arpeggio)
                arpeggioSound = data.arpeggioSound
            }
            if padSound != data.padSound {
                useSound(data.padSound, synthesizer: .pad)
                padSound = data.padSound
            }
            if bassSound != data.bassSound {
                useSound(data.bassSound, synthesizer: .bass)
                bassSound = data.bassSound
            }
            adjustVolume(data.arpeggioVolume, instrument: .arpeggio)
            adjustVolume(data.padVolume, instrument: .pad)
            adjustVolume(data.bassVolume, instrument: .bass)
            adjustVolume(data.drumVolume, instrument: .drum)
            adjustFilterFrequency(data.filterFrequency)
            if length != data.length {
                setLength(Double(data.length))
                length = data.length
            }
        }
    }

    init() {
        mixer = Mixer(arpeggioSynthesizer, padSynthesizer, bassSynthesizer, drumKit)
        filter = MoogLadder(mixer)
        filter?.cutoffFrequency = 20000
        engine.output = filter

        do {
            useSound(.square, synthesizer: .arpeggio)
            useSound(.saw, synthesizer: .pad)
            useSound(.saw, synthesizer: .bass)
            if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/drumSimp", withExtension: "exs") {
                try drumKit.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("A file was not found.")
        }
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }

        sequencer = AppleSequencer(fromURL: Bundle.module.url(forResource: "MIDI Files/Demo", withExtension: "mid")!)
        sequencer.enableLooping()
        sequencer.tracks[1].setMIDIOutput(arpeggioSynthesizer.midiIn)
        sequencer.tracks[2].setMIDIOutput(bassSynthesizer.midiIn)
        sequencer.tracks[3].setMIDIOutput(padSynthesizer.midiIn)
        sequencer.tracks[4].setMIDIOutput(drumKit.midiIn)
    }

    func adjustVolume(_ volume: AUValue, instrument: Instrument) {
        switch instrument {
        case .arpeggio:
            arpeggioSynthesizer.volume = volume
        case .pad:
            padSynthesizer.volume = volume
        case .bass:
            bassSynthesizer.volume = volume
        case .drum:
            drumKit.volume = volume
        }
    }

    func adjustFilterFrequency(_ frequency: Float) {
        filter?.cutoffFrequency = frequency.denormalized(to: 30 ... 20000, taper: 3)
    }

    func rewindSequence() {
        sequencer.rewind()
    }

    func setLength(_ length: Double) {
        guard round(sequencer.length.beats) != round(4.0 * length) else { return }
        sequencer.setLength(Duration(beats: 16))
        for track in sequencer.tracks {
            track.resetToInit()
        }
        sequencer.setLength(Duration(beats: length))
        sequencer.setLoopInfo(Duration(beats: length), loopCount: 0)
        sequencer.rewind()
    }

    func useSound(_ sound: Sound, synthesizer: Synthesizer) {
        var path = "Sounds/Sampler Instruments/"
        switch sound {
        case .square:
            path += "sqrTone1"
        case .saw:
            path += "sawPiano1"
        case .pad:
            path += "sawPad1"
        case .noisy:
            path += "noisyRez"
        }

        do {
            switch synthesizer {
            case .arpeggio:
                if let fileURL = Bundle.main.url(forResource: path, withExtension: "exs") {
                    try arpeggioSynthesizer.loadInstrument(url: fileURL)
                } else {
                    Log("Could not find file")
                }
            case .pad:
                if let fileURL = Bundle.main.url(forResource: path, withExtension: "exs") {
                    try padSynthesizer.loadInstrument(url: fileURL)
                } else {
                    Log("Could not find file")
                }
            case .bass:
                if let fileURL = Bundle.main.url(forResource: path, withExtension: "exs") {
                    try bassSynthesizer.loadInstrument(url: fileURL)
                } else {
                    Log("Could not find file")
                }
            }
        } catch {
            Log("Could not load instrument")
        }
    }

    func adjustTempo(_ tempo: Float) {
        sequencer?.setTempo(Double(tempo))
    }
}

struct MusicToyView: View {
    @StateObject var conductor = MusicToyConductor()

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Spacer()
                Image(systemName: "backward").onTapGesture {
                    conductor.rewindSequence()
                }
                Spacer()
                Image(systemName: conductor.data.isPlaying ? "stop" : "play").onTapGesture {
                    conductor.data.isPlaying.toggle()
                }
                Spacer()
                Text("Bars")
                Picker("Bars", selection: $conductor.data.length) {
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("4").tag(4)
                    Text("8").tag(8)
                    Text("16").tag(16)
                }.pickerStyle(SegmentedPickerStyle())
            }
            HStack {
                CookbookKnob(text: "Tempo",
                             parameter: $conductor.data.tempo,
                             range: 20 ... 300).padding(5)
                CookbookKnob(text: "Filter Frequency",
                             parameter: $conductor.data.filterFrequency,
                             range: 0 ... 1).padding(5)
            }
            HStack {
                Text("Arpeggio")
                Picker("Arpeggio", selection: $conductor.data.arpeggioSound) {
                    Text("Square").tag(Sound.square)
                    Text("Saw").tag(Sound.saw)
                    Text("Noise").tag(Sound.noisy)
                }.pickerStyle(SegmentedPickerStyle())
            }
            HStack {
                Text("Chords")
                Picker("Chords", selection: $conductor.data.padSound) {
                    Text("Square").tag(Sound.square)
                    Text("Saw").tag(Sound.saw)
                    Text("Pad").tag(Sound.pad)
                }.pickerStyle(SegmentedPickerStyle())
            }
            HStack {
                Text("Bass")
                Picker("Bass", selection: $conductor.data.bassSound) {
                    Text("Square").tag(Sound.square)
                    Text("Saw").tag(Sound.saw)
                }.pickerStyle(SegmentedPickerStyle())
            }
            HStack {
                CookbookKnob(text: "Drums Volume",
                             parameter: $conductor.data.drumVolume,
                             range: 0.5 ... 1).padding(5)
                CookbookKnob(text: "Arpeggio Volume",
                             parameter: $conductor.data.arpeggioVolume,
                             range: 0.5 ... 1).padding(5)
                CookbookKnob(text: "Chords Volume",
                             parameter: $conductor.data.padVolume,
                             range: 0.5 ... 1).padding(5)
                CookbookKnob(text: "Bass Volume",
                             parameter: $conductor.data.bassVolume,
                             range: 0.5 ... 1).padding(5)
            }
        }
        .padding()
        .cookbookNavBarTitle("Music Toy")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
