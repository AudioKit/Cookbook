import AudioKit
import AudioKitUI
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
    @State var showSection = Array(repeating: false, count: 11)
    let rowColor = Color(.systemGray6)

    var body: some View {
        Form {
            Section(header: Text("Categories")) {
                Group {
                    DisclosureGroup("Mini Apps") {
                        Group {
                            NavigationLink("Drum Pads", destination: DrumsView())
                                .listRowBackground(rowColor)
                            NavigationLink("Drum Sequencer", destination: DrumSequencerView())
                                .listRowBackground(rowColor)
                            NavigationLink("Drum Synthesizers", destination: DrumSynthesizersView())
                                .listRowBackground(rowColor)
                            NavigationLink("Graphic Equalizer", destination: GraphicEqualizerView())
                                .listRowBackground(rowColor)
                            NavigationLink("Instrument EXS", destination: InstrumentEXSView())
                                .listRowBackground(rowColor)
                            NavigationLink("Instrument SFZ", destination: InstrumentSFZView())
                                .listRowBackground(rowColor)
                        }
                        Group {
                            NavigationLink("Music Toy", destination: MusicToyView())
                                .listRowBackground(rowColor)
                            NavigationLink("Telephone", destination: Telephone())
                                .listRowBackground(rowColor)
                            NavigationLink("Tuner", destination: TunerView())
                                .listRowBackground(rowColor)
                            NavigationLink("Noise Generators", destination: NoiseGeneratorsView())
                                .listRowBackground(rowColor)
                            NavigationLink("Vocal Tract", destination: VocalTractView())
                                .listRowBackground(rowColor)
                            NavigationLink("MIDI Monitor", destination: MIDIMonitorView())
                                .listRowBackground(rowColor)
                            NavigationLink("MIDI Track View", destination: MIDITrackDemo())
                                .listRowBackground(rowColor)
                            NavigationLink("Recorder", destination: RecorderView())
                                .listRowBackground(rowColor)
                        }
                        // TODO:
                        // Text("Level Meter")
                        // Text("Sequencer")
                        // Text("MIDI Controller") - MIDI Output Sender
                    }
                }
                Group {
                    DisclosureGroup("Uncategorized Demos") {
                        Group {
                            NavigationLink("Audio Files View", destination: AudioFileRecipeView())
                                .listRowBackground(rowColor)
                            NavigationLink("Callback Instrument", destination: CallbackInstrumentView())
                                .listRowBackground(rowColor)
                            NavigationLink("Tables", destination: TableRecipeView())
                                .listRowBackground(rowColor)
                        }
                    }
                }
                Group {
                    DisclosureGroup("Operations") {
                        Group {
                            NavigationLink("Crossing Signal", destination: CrossingSignalView())
                                .listRowBackground(rowColor)
                            NavigationLink("Drone Operation", destination: DroneOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Instrument Operation", destination: InstrumentOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("LFO Operation", destination: LFOOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Phasor Operation", destination: PhasorOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Pitch Shift Operation", destination: PitchShiftOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Segment Operation", destination: SegmentOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Smooth Delay Operation", destination: SmoothDelayOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Stereo Operation", destination: StereoOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Stereo Delay Operation", destination: StereoDelayOperationView())
                                .listRowBackground(rowColor)
                        }
                        Group {
                            NavigationLink("Variable Delay Operation", destination: VariableDelayOperationView())
                                .listRowBackground(rowColor)
                            NavigationLink("Vocal Fun", destination: VocalTractOperationView())
                                .listRowBackground(rowColor)
                        }
                    }
                }
                Group {
                    DisclosureGroup("Physical Models") {
                        Group {
                            NavigationLink(destination: PluckedStringView()) {
                                Text("Plucked String")
                            }
                            .listRowBackground(rowColor)
                            Text("More at STKAudioKit").onTapGesture {
                                if let url = URL(string: "https://www.audiokit.io/STKAudioKit/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .listRowBackground(rowColor)
                            .foregroundColor(.blue)
                        }
                    }
                }
                Group {
                    DisclosureGroup("Effects") {
                        Group {
                            NavigationLink("Auto Panner", destination: AutoPannerView())
                                .listRowBackground(rowColor)
                            NavigationLink("Auto Wah", destination: AutoWahView())
                                .listRowBackground(rowColor)
                            NavigationLink("Balancer", destination: BalancerView())
                                .listRowBackground(rowColor)
                            NavigationLink("Chorus", destination: ChorusView())
                                .listRowBackground(rowColor)
                            NavigationLink("Compressor", destination: CompressorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Convolution", destination: ConvolutionView())
                                .listRowBackground(rowColor)
                            NavigationLink("Delay", destination: DelayView())
                                .listRowBackground(rowColor)
                            NavigationLink("Dynamic Range Compressor", destination: DynamicRangeCompressorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Expander", destination: ExpanderView())
                                .listRowBackground(rowColor)
                            NavigationLink("Flanger", destination: FlangerView())
                                .listRowBackground(rowColor)
                        }
                        Group {
                            NavigationLink("MultiTap Delay", destination: MultiTapDelayView())
                                .listRowBackground(rowColor)
                            NavigationLink("Panner", destination: PannerView())
                                .listRowBackground(rowColor)
                            NavigationLink("Peak Limiter", destination: PeakLimiterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Phaser", destination: PhaserView())
                                .listRowBackground(rowColor)
                            NavigationLink("Phase-Locked Vocoder", destination: PhaseLockedVocoderView())
                                .listRowBackground(rowColor)
                            NavigationLink("Playback Speed", destination: PlaybackSpeedView())
                                .listRowBackground(rowColor)
                            NavigationLink("Pitch Shifter", destination: PitchShifterView())
                                .listRowBackground(rowColor)
                            NavigationLink("String Resonator", destination: StringResonatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Time / Pitch", destination: TimePitchView())
                                .listRowBackground(rowColor)
                            NavigationLink("Transient Shaper", destination: TransientShaperView())
                                .listRowBackground(rowColor)
                        }
                        Group {
                            NavigationLink("Tremolo", destination: TremoloView())
                                .listRowBackground(rowColor)
                            NavigationLink("Variable Delay", destination: VariableDelayView())
                                .listRowBackground(rowColor)
                        }
                    }
                }
                Group {
                    DisclosureGroup("Distortion") {
                        Group {
                            NavigationLink("Bit Crusher", destination: BitCrusherView())
                                .listRowBackground(rowColor)
                            NavigationLink("Decimator", destination: DecimatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Clipper", destination: ClipperView())
                                .listRowBackground(rowColor)
                            NavigationLink("Ring Modulator", destination: RingModulatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Tanh Distortion", destination: TanhDistortionView())
                                .listRowBackground(rowColor)
                        }
                    }
                }
                Group {
                    DisclosureGroup("Reverb") {
                        Group {
                            NavigationLink("Chowning Reverb", destination: ChowningReverbView())
                                .listRowBackground(rowColor)
                            NavigationLink("Comb Filter Reverb", destination: CombFilterReverbView())
                                .listRowBackground(rowColor)
                            NavigationLink("Costello Reverb", destination: CostelloReverbView())
                                .listRowBackground(rowColor)
                            NavigationLink("Flat Frequency Response Reverb",
                                destination: FlatFrequencyResponseReverbView())
                                .listRowBackground(rowColor)
                            NavigationLink("Apple Reverb", destination: ReverbView())
                                .listRowBackground(rowColor)
                            NavigationLink("Zita Reverb", destination: ZitaReverbView())
                                .listRowBackground(rowColor)
                        }
                    }
                }
                Group {
                    DisclosureGroup("Filters") {
                        Group {
                            NavigationLink("Band Pass Butterworth Filter",
                                destination: BandPassButterworthFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Band Reject Butterworth Filter",
                                destination: BandRejectButterworthFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Equalizer Filter", destination: EqualizerFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Formant Filter", destination: FormantFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("High Pass Butterworth Filter",
                                destination: HighPassButterworthFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("High Pass Filter", destination: HighPassFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("High Shelf Filter", destination: HighShelfFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("High Shelf Parametric Equalizer Filter",
                                destination: HighShelfParametricEqualizerFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Korg Low Pass Filter", destination: KorgLowPassFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Low Pass Butterworth Filter",
                                destination: LowPassButterworthFilterView())
                                .listRowBackground(rowColor)
                        }
                        Group {
                            NavigationLink("Low Pass Filter", destination: LowPassFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Low Shelf Filter", destination: LowShelfFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Low Shelf Parametric Equalizer Filter",
                                destination: LowShelfParametricEqualizerFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Modal Resonance Filter", destination: ModalResonanceFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Moog Ladder", destination: MoogLadderView())
                                .listRowBackground(rowColor)
                            NavigationLink("Peaking Parametric Equalizer Filter",
                                destination: PeakingParametricEqualizerFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Resonant Filter", destination: ResonantFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Roland Tb303 Filter", destination: RolandTB303FilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Three Pole Lowpass Filter", destination: ThreePoleLowpassFilterView())
                                .listRowBackground(rowColor)
                            NavigationLink("Tone Filter", destination: ToneFilterView())
                                .listRowBackground(rowColor)
                        }
                        Group {
                            NavigationLink("Tone Complement Filter", destination: ToneComplementFilterView())
                                .listRowBackground(rowColor)
                        }
                    }

                    DisclosureGroup("Oscillators") {
                        Group {
                            NavigationLink("Amplitude Envelope", destination: AmplitudeEnvelopeView())
                                .listRowBackground(rowColor)
                            NavigationLink("Dynamic Oscillator", destination: DynamicOscillatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("FM Frequency Modulation", destination: FMOscillatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Waveform Morphing", destination: MorphingOscillatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Sine", destination: OscillatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Phase Distortion", destination: PhaseDistortionOscillatorView())
                                .listRowBackground(rowColor)
                            NavigationLink("Pulse Width Modulation", destination: PWMOscillatorView())
                                .listRowBackground(rowColor)
                        }
                    }

                    DisclosureGroup("Audio Player") {
                        Group {
                            NavigationLink("Completion Handler", destination: AudioPlayerCompletionHandler())
                                .listRowBackground(rowColor)
                            NavigationLink("Multi Segment Player", destination: MultiSegmentPlayerView())
                                .listRowBackground(rowColor)
                            NavigationLink("Playlist", destination: PlaylistView())
                                .listRowBackground(rowColor)
                        }
                    }

                    DisclosureGroup("WIP") {
                        Group {
                            NavigationLink("MIDI Port Test", destination: MIDIPortTestView())
                                .listRowBackground(rowColor)
                            NavigationLink("Channel/Device Routing", destination: ChannelDeviceRoutingView())
                                .listRowBackground(rowColor)
                            NavigationLink("Base Tap Demo", destination: BaseTapDemoView())
                                .listRowBackground(rowColor)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("AudioKit")
        .background(Color(.systemGray5))
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
        }
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
