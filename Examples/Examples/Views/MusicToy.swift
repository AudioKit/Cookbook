import AudioKit
import AVFoundation
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

class MusicToyConductor: ObservableObject {
    private var engine = AKEngine()
    private var sequencer: AKAppleSequencer!
    private var mixer = AKMixer()
    private var arpeggioSynthesizer = AKMIDISampler(name: "Arpeggio Synth")
    private var padSynthesizer = AKMIDISampler(name: "Pad Synth")
    private var bassSynthesizer = AKMIDISampler(name: "Bass Synth")
    private var drumKit = AKMIDISampler(name: "Drums")
    private var filter: AKMoogLadder?

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
        mixer = AKMixer(arpeggioSynthesizer, padSynthesizer, bassSynthesizer, drumKit)
        filter = AKMoogLadder(mixer)
        filter?.cutoffFrequency = 20_000
        engine.output = filter

    }
    func start() {
        do {
            useSound(.square, synthesizer: .arpeggio)
            useSound(.saw, synthesizer: .pad)
            useSound(.saw, synthesizer: .bass)
            try drumKit.loadEXS24("Sounds/Sampler Instruments/drumSimp")
        } catch {
            AKLog("A file was not found.")
        }
        do {
            try engine.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

        sequencer = AKAppleSequencer(filename: "seqDemo")
        sequencer.enableLooping()
        sequencer.tracks[1].setMIDIOutput(arpeggioSynthesizer.midiIn)
        sequencer.tracks[2].setMIDIOutput(bassSynthesizer.midiIn)
        sequencer.tracks[3].setMIDIOutput(padSynthesizer.midiIn)
        sequencer.tracks[4].setMIDIOutput(drumKit.midiIn)
    }

    func stop() {
        sequencer.stop()
        engine.stop()
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
        filter?.cutoffFrequency = frequency.denormalized(to: 30 ... 20_000, taper: 3)
    }

    func rewindSequence() {
        sequencer.rewind()
    }

    func setLength(_ length: Double) {
        guard round(sequencer.length.beats) != round(4.0 * length) else { return }
        sequencer.setLength(AKDuration(beats: 16))
        for track in sequencer.tracks {
            track.resetToInit()
        }
        sequencer.setLength(AKDuration(beats: length))
        sequencer.setLoopInfo(AKDuration(beats: length), numberOfLoops: 0)
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
                try arpeggioSynthesizer.loadEXS24(path)
            case .pad:
                try padSynthesizer.loadEXS24(path)
            case .bass:
                try bassSynthesizer.loadEXS24(path)
            }
        } catch {
            AKLog("Could not load EXS24")
        }
    }

    func adjustTempo(_ tempo: Float) {
        sequencer?.setTempo(Double(tempo))
    }
}


struct MusicToyView: View {
    @ObservedObject var conductor = MusicToyConductor()

    var body: some View {

        ScrollView {
            HStack(spacing: 20) {
                Spacer()
                Image(systemName: "backward").onTapGesture {
                    self.conductor.rewindSequence()
                }
                Spacer()
                Image(systemName: conductor.data.isPlaying ? "stop" : "play" ).onTapGesture {
                    self.conductor.data.isPlaying.toggle()
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
            ParameterSlider(text: "Tempo",
                            parameter: self.$conductor.data.tempo,
                            range: 20 ... 300).padding(5)
            ParameterSlider(text: "Drums Volume",
                            parameter: self.$conductor.data.drumVolume,
                            range: 0.5 ... 1).padding(5)
            VStack {
                HStack {
                    Text("Arpeggio")
                    Picker("Arpeggio", selection: $conductor.data.arpeggioSound) {
                        Text("Square").tag(Sound.square)
                        Text("Saw").tag(Sound.saw)
                        Text("Noise").tag(Sound.noisy)
                    }.pickerStyle(SegmentedPickerStyle())
                }
                ParameterSlider(text: "Arpeggio Volume",
                                parameter: self.$conductor.data.arpeggioVolume,
                                range: 0.5 ... 1).padding(5)
            }
            VStack {
                HStack {
                    Text("Chords")
                    Picker("Chords", selection: $conductor.data.padSound) {
                        Text("Square").tag(Sound.square)
                        Text("Saw").tag(Sound.saw)
                        Text("Pad").tag(Sound.pad)
                    }.pickerStyle(SegmentedPickerStyle())
                }
                ParameterSlider(text: "Chords Volume",
                                parameter: self.$conductor.data.padVolume,
                                range: 0.5 ... 1).padding(5)
            }

            VStack {
                HStack {
                    Text("Bass")
                    Picker("Bass", selection: $conductor.data.bassSound) {
                        Text("Square").tag(Sound.square)
                        Text("Saw").tag(Sound.saw)
                    }.pickerStyle(SegmentedPickerStyle())
                }
                ParameterSlider(text: "Bass Volume",
                                parameter: self.$conductor.data.bassVolume,
                                range: 0.5 ... 1).padding(5)
            }
            ParameterSlider(text: "Filter Frequency",
                            parameter: self.$conductor.data.filterFrequency,
                            range: 0 ... 1).padding(5)
        }
        .padding()
        .navigationBarTitle(Text("Music Toy"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct MusicToy_Previews: PreviewProvider {
    static var previews: some View {
        MusicToyView()
    }
}
