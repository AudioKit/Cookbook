import AudioKit
import AVFoundation
import SwiftUI

struct ContentView: View {

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
            Section(header: Text("Mini Apps")
                        .padding(.top, 20)) {
                Section {
                    NavigationLink(destination: DrumsView()) { Text("Drum Pads") }
                    NavigationLink(destination: DrumSequencerView()) { Text("Drum Sequencer") }
                    NavigationLink(destination: DrumSynthesizersView()) { Text("Drum Synthesizers") }
                    NavigationLink(destination: GraphicEqualizerView()) { Text("Graphic Equalizer") }
                    NavigationLink(destination: MusicToyView()) { Text("Music Toy") }
                    NavigationLink(destination: Telephone()) { Text("Telephone") }
                    NavigationLink(destination: TunerView()) { Text("Tuner") }
                    NavigationLink(destination: NoiseGeneratorsView()) { Text("Noise Generators") }
                    NavigationLink(destination: VocalTractView()) { Text("Vocal Tract") }
                    NavigationLink(destination: MIDIMonitorView()) { Text("MIDI Monitor") }
                }
                Section {
                    NavigationLink(destination: RecorderView()) { Text("Recorder") }
                    // TODO
                    // Text("Level Meter")
                    // Text("Metronome")
                    // Text("Sequencer")
                    // Text("MIDI Controller") - MIDI Output Sender
                }
            }
            Section(header: Text("Uncategorized Demos")) {
                Section {
                    NavigationLink(destination: CallbackInstrumentView()) { Text("Callback Instrument") }
                    NavigationLink(destination: TableRecipeView()) { Text("Tables") }
                }
            }

            Section(header: Text("Operations")) {
                Section {
                    NavigationLink(destination: CrossingSignalView()) { Text("Crossing Signal") }
                    NavigationLink(destination: DroneOperationView()) { Text("Drone Operation") }
                    NavigationLink(destination: InstrumentOperationView()) { Text("Instrument Operation") }
                    NavigationLink(destination: LFOOperationView()) { Text("LFO Operation") }
                    NavigationLink(destination: PhasorOperationView()) { Text("Phasor Operation") }
                    NavigationLink(destination: PitchShiftOperationView()) { Text("Pitch Shift Operation") }
                    NavigationLink(destination: SegmentOperationView()) { Text("Segment Operation") }
                    NavigationLink(destination: SmoothDelayOperationView()) { Text("Smooth Delay Operation") }
                    NavigationLink(destination: StereoOperationView()) { Text("Stereo Operation") }
                    NavigationLink(destination: StereoDelayOperationView()) { Text("Stereo Delay Operation") }
                }
                Section{
                    NavigationLink(destination: VariableDelayOperationView()) { Text("Variable Delay Operation") }
                    NavigationLink(destination: VocalTractOperationView()) { Text("Vocal Fun") }
                }
            }
            Section(header: Text("Physical Models")) {
                NavigationLink(destination: FluteView()) { Text("Flute") }
                NavigationLink(destination: DrippingSoundsView()) { Text("Dripping Sounds") }
                NavigationLink(destination: ShakerView()) { Text("Shaker") }
            }

            Section(header: Text("Effects")) {
                Section {
                    NavigationLink(destination: AutoPannerView()) { Text("Auto Panner") }
                    NavigationLink(destination: AutoWahView()) { Text("Auto Wah") }
                    NavigationLink(destination: BalancerView()) { Text("Balancer") }
                    NavigationLink(destination: ChorusView()) { Text("Chorus") }
                    NavigationLink(destination: CompressorView()) { Text("Compressor") }
                    NavigationLink(destination: ConvolutionView()) { Text("Convolution") }
                    NavigationLink(destination: DelayView()) { Text("Delay") }
                    NavigationLink(destination: DynamicRangeCompressorView()) { Text("Dynamic Range Compressor") }
                    NavigationLink(destination: ExpanderView()) { Text("Expander") }
                    NavigationLink(destination: FlangerView()) { Text("Flanger") }
                }
                Section {
                    NavigationLink(destination: MultiTapDelayView()) { Text("MultiTap Delay") }
                    NavigationLink(destination: PannerView()) { Text("Panner") }
                    NavigationLink(destination: PeakLimiterView()) { Text("Peak Limiter") }
                    NavigationLink(destination: PhaserView()) { Text("Phaser") }
                    NavigationLink(destination: PhaseLockedVocoderView()) { Text("Phase-Locked Vocoder") }
                    NavigationLink(destination: PlaybackSpeedView()) { Text("Playback Speed") }
                    NavigationLink(destination: PitchShifterView()) { Text("Pitch Shifter") }
                    NavigationLink(destination: StringResonatorView()) { Text("String Resonator") }
                    NavigationLink(destination: TimePitchView()) { Text("Time / Pitch") }
                    NavigationLink(destination: TremoloView()) { Text("Tremolo") }

                }
                Section {
                    NavigationLink(destination: VariableDelayView()) { Text("Variable Delay") }
                }
            }
            Section(header: Text("Distortion")) {
                NavigationLink(destination: BitCrusherView()) { Text("Bit Crusher") }
                NavigationLink(destination: DecimatorView()) { Text("Decimator") }
                NavigationLink(destination: ClipperView()) { Text("Clipper") }
                NavigationLink(destination: RingModulatorView()) { Text("Ring Modulator") }
                NavigationLink(destination: TanhDistortionView()) { Text("Tanh Distortion") }
            }
            Section(header: Text("Reverb")) {
                NavigationLink(destination: ChowningReverbView()) { Text("Chowning Reverb") }
                NavigationLink(destination: CombFilterReverbView()) { Text("Comb Filter Reverb") }
                NavigationLink(destination: CostelloReverbView()) { Text("Costello Reverb") }
                NavigationLink(destination: FlatFrequencyResponseReverbView()) { Text("Flat Frequency Response Reverb") }
                NavigationLink(destination: ReverbView()) { Text("Apple Reverb") }
                NavigationLink(destination: ZitaReverbView()) { Text("Zita Reverb") }
            }
            Section(header: Text("Filters")) {
                Section {
                    NavigationLink(destination: BandPassButterworthFilterView()) { Text("Band Pass Butterworth Filter") }
                    NavigationLink(destination: BandRejectButterworthFilterView()) { Text("Band Reject Butterworth Filter") }
                    NavigationLink(destination: EqualizerFilterView()) { Text("Equalizer Filter") }
                    NavigationLink(destination: FormantFilterView()) { Text("Formant Filter") }
                    NavigationLink(destination: HighPassButterworthFilterView()) { Text("High Pass Butterworth Filter") }
                    NavigationLink(destination: HighPassFilterView()) { Text("High Pass Filter") }
                    NavigationLink(destination: HighShelfFilterView()) { Text("High Shelf Filter") }
                    NavigationLink(destination: HighShelfParametricEqualizerFilterView()) { Text("High Shelf Parametric Equalizer Filter") }
                    NavigationLink(destination: KorgLowPassFilterView()) { Text("Korg Low Pass Filter") }
                    NavigationLink(destination: LowPassButterworthFilterView()) { Text("Low Pass Butterworth Filter") }
                }
                Section {
                    NavigationLink(destination: LowPassFilterView()) { Text("Low Pass Filter") }
                    NavigationLink(destination: LowShelfFilterView()) { Text("Low Shelf Filter") }
                    NavigationLink(destination: LowShelfParametricEqualizerFilterView()) { Text("Low Shelf Parametric Equalizer Filter") }
                    NavigationLink(destination: ModalResonanceFilterView()) { Text("Modal Resonance Filter") }
                    NavigationLink(destination: MoogLadderView()) { Text("Moog Ladder") }
                    NavigationLink(destination: PeakingParametricEqualizerFilterView()) { Text("Peaking Parametric Equalizer Filter") }
                    NavigationLink(destination: ResonantFilterView()) { Text("Resonant Filter") }
                    NavigationLink(destination: RolandTB303FilterView()) { Text("Roland Tb303 Filter") }
                    NavigationLink(destination: ThreePoleLowpassFilterView()) { Text("Three Pole Lowpass Filter") }
                    NavigationLink(destination: ToneFilterView()) { Text("Tone Filter") }
                }
                Section {
                    NavigationLink(destination: ToneComplementFilterView()) { Text("Tone Complement Filter") }
                }
            }
            Section(header: Text("Oscillators")) {
                NavigationLink(destination: AmplitudeEnvelopeView()) { Text("Amplitude Envelope") }
                NavigationLink(destination: FMOscillatorView()) { Text("FM Frequency Modulation") }
                NavigationLink(destination: MorphingOscillatorView()) { Text("Waveform Morphing") }
                NavigationLink(destination: OscillatorView()) { Text("Sine") }
                NavigationLink(destination: PhaseDistortionOscillatorView()) { Text("Phase Distortion ") }
                NavigationLink(destination: PWMOscillatorView()) { Text("Pulse Width Modulation") }
            }
        }
        .navigationBarTitle("AudioKit", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("audiokit-logo")
                    .resizable()
                    .frame(width: 117,
                           height: 20)
            }
        }
        .font(.system(.body, design: .rounded))
    }
}

struct DetailView: View {
    @State private var opacityValue = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            Image("audiokit-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3)
            Image("audiokit-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 217,
                       height: 120)
            Text("Welcome to the AudioKit Cookbook")
                .font(.system(.largeTitle, design: .rounded))
                .padding()
            Text("Please select a recipe from the left-side menu.")
                .font(.system(.body, design: .rounded))
        }
        .opacity(opacityValue)
        .onAppear {
            DispatchQueue.main
                .asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        opacityValue = 1.0
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
