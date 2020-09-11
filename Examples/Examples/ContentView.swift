import SwiftUI
import AVFoundation
import AudioKit

struct ContentView: View {
    @State private var dates = [Date]()

    var body: some View {
        NavigationView {
            MasterView()
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct MasterView: View {

    var body: some View {
        Form {
            Section(header: Text("Mini Apps")) {
                NavigationLink(destination: DrumsView()) { Text("Drum Pads") }
                NavigationLink(destination: MusicToyView()) { Text("Music Toy") }
                NavigationLink(destination: Telephone()) { Text("Telephone") }
                NavigationLink(destination: TunerView()) { Text("Tuner") }
                NavigationLink(destination: NoiseGeneratorsView()) { Text("Noise Generator") }
                NavigationLink(destination: VocalTractView()) { Text("Vocal Tract") }
                NavigationLink(destination: MIDIMonitorView()) { Text("MIDI Monitor") }
                NavigationLink(destination: RecorderView()) { Text("Recorder") }
            }
            Section(header: Text("Coming soon")) {
                Text("Metronome")
                Text("Sequencer")
                Text("Bass 808")
                Text("Digital D1")
                Text("Hey Metronome")
                Text("Retro Piano")
                Text("Synth One")
            }

            Section(header: Text("Effects")) {
                NavigationLink(destination: AutoWahView()) { Text("Auto Wah") }
                NavigationLink(destination: DelayView()) { Text("Delay") }
                NavigationLink(destination: DynamicRangeCompressorView()) { Text("Dynamic Range Compressor") }
                NavigationLink(destination: PannerView()) { Text("Panner") }
                NavigationLink(destination: PhaserView()) { Text("Phaser") }
                NavigationLink(destination: PitchShifterView()) { Text("Pitch Shifter") }
                NavigationLink(destination: StringResonatorView()) { Text("String Resonator") }
                NavigationLink(destination: TremoloView()) { Text("Tremolo") }
                NavigationLink(destination: VariableDelayView()) { Text("Variable Delay") }
            }
            Section(header: Text("Distortion")) {
                NavigationLink(destination: BitCrusherView()) { Text("Bit Crusher") }
                NavigationLink(destination: ClipperView()) { Text("Clipper") }
                NavigationLink(destination: TanhDistortionView()) { Text("Tanh Distortion") }
            }
            Section(header: Text("Reverb")) {
                NavigationLink(destination: ChowningReverbView()) { Text("Chowning Reverb") }
                NavigationLink(destination: CombFilterReverbView()) { Text("Comb Filter Reverb") }
                NavigationLink(destination: CostelloReverbView()) { Text("Costello Reverb") }
                NavigationLink(destination: FlatFrequencyResponseReverbView()) { Text("Flat Frequency Response Reverb") }
                NavigationLink(destination: ZitaReverbView()) { Text("Zita Reverb") }

            }
            Section(header: Text("Boutique Filters")) {
                NavigationLink(destination: KorgLowPassFilterView()) { Text("Korg Low Pass Filter") }
                NavigationLink(destination: MoogLadderView()) { Text("Moog Ladder") }
                NavigationLink(destination: RolandTB303FilterView()) { Text("Roland Tb303 Filter") }
            }
            Section(header: Text("Butterworth Filters")) {
                NavigationLink(destination: BandPassButterworthFilterView()) { Text("Band Pass Butterworth Filter") }
                NavigationLink(destination: BandRejectButterworthFilterView()) { Text("Band Reject Butterworth Filter") }
                NavigationLink(destination: HighPassButterworthFilterView()) { Text("High Pass Butterworth Filter") }
                NavigationLink(destination: LowPassButterworthFilterView()) { Text("Low Pass Butterworth Filter") }
            }
            Section(header: Text("Parametric EQ Filters")) {
                NavigationLink(destination: HighShelfParametricEqualizerFilterView()) { Text("High Shelf Parametric Equalizer Filter") }
                NavigationLink(destination: LowShelfParametricEqualizerFilterView()) { Text("Low Shelf Parametric Equalizer Filter") }
                NavigationLink(destination: PeakingParametricEqualizerFilterView()) { Text("Peaking Parametric Equalizer Filter") }
            }
            Section(header: Text("More Filters")) {
                NavigationLink(destination: EqualizerFilterView()) { Text("Equalizer Filter") }
                NavigationLink(destination: FormantFilterView()) { Text("Formant Filter") }
                NavigationLink(destination: ThreePoleLowpassFilterView()) { Text("Three Pole Lowpass Filter") }
                NavigationLink(destination: ModalResonanceFilterView()) { Text("Modal Resonance Filter") }
                NavigationLink(destination: ResonantFilterView()) { Text("Resonant Filter") }
                NavigationLink(destination: ToneFilterView()) { Text("Tone Filter") }
                NavigationLink(destination: ToneComplementFilterView()) { Text("Tone Complement Filter") }
            }
            Section(header: Text("Oscillators")) {
                NavigationLink(destination: AmplitudeEnvelopeView()) { Text("Amplitude Envelope") }
                NavigationLink(destination: FMOscillatorView()) { Text("FM Frequency Modulation") }
                NavigationLink(destination: MorphingOscillatorView()) { Text("Waveform Morphing") }
                NavigationLink(destination: OscillatorView()) { Text("Sine") }
                NavigationLink(destination: PhaseDistortionOscillatorView()) { Text("Phase Distortion ") }
                NavigationLink(destination: PWMOscillatorView()) { Text("Pulse Width Modulation") }
            }


        }.navigationBarTitle(Text("AudioKit"))
    }
}

struct DetailView: View {
    var body: some View {
        ZStack { Text("Detail View") }.navigationBarTitle(Text("Examples"))
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
