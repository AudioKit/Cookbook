import SwiftUI

public struct ContentView: View {
    public init() {}
    public var body: some View {
        NavigationView {
            MasterView()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MasterView: View {
    @State private var showingInfo = false
    var body: some View {
        Form {
            Section(header: Text("Categories")) {
                Group {
                    DisclosureGroup("Mini Apps") {
                        Group {
                            NavigationLink("Arpeggiator", destination: ArpeggiatorView())
                            NavigationLink("Audio 3D", destination: AudioKit3DView())
                            NavigationLink("Drum Pads", destination: DrumsView())
                            NavigationLink("Drum Sequencer", destination: DrumSequencerView())
                            NavigationLink("Drum Synthesizers", destination: DrumSynthesizersView())
                            NavigationLink("Graphic Equalizer", destination: GraphicEqualizerView())
                            NavigationLink("Instrument EXS", destination: InstrumentEXSView())
                            NavigationLink("Instrument SFZ", destination: InstrumentSFZView())
                        }
                        Group {
                            NavigationLink("MIDI Monitor", destination: MIDIMonitorView())
                            NavigationLink("MIDI Track View", destination: MIDITrackDemo())
                            NavigationLink("Music Toy", destination: MusicToyView())
                            NavigationLink("Noise Generators", destination: NoiseGeneratorsView())
                            NavigationLink("Recorder", destination: RecorderView())
                            NavigationLink("SpriteKit Audio", destination: SpriteKitAudioView())
                            NavigationLink("Telephone", destination: Telephone())
                            NavigationLink("Tuner", destination: TunerView())
                            NavigationLink("Vocal Tract", destination: VocalTractView())
                        }
                    }
                }

                Group {
                    DisclosureGroup("Operations") {
                        Group {
                            NavigationLink("Crossing Signal", destination: CrossingSignalView())
                            NavigationLink("Drone Operation", destination: DroneOperationView())
                            NavigationLink("Instrument Operation", destination: InstrumentOperationView())
                            NavigationLink("LFO Operation", destination: LFOOperationView())
                            NavigationLink("Phasor Operation", destination: PhasorOperationView())
                            NavigationLink("Pitch Shift Operation", destination: PitchShiftOperationView())
                            NavigationLink("Segment Operation", destination: SegmentOperationView())
                            NavigationLink("Smooth Delay Operation", destination: SmoothDelayOperationView())
                            NavigationLink("Stereo Operation", destination: StereoOperationView())
                            NavigationLink("Stereo Delay Operation", destination: StereoDelayOperationView())
                        }
                        Group {
                            NavigationLink("Variable Delay Operation", destination: VariableDelayOperationView())
                            NavigationLink("Vocal Fun", destination: VocalTractOperationView())
                        }
                    }
                }

                Group {
                    DisclosureGroup("Physical Models") {
                        Group {
                            NavigationLink(destination: PluckedStringView()) {
                                Text("Plucked String")
                            }
                            Text("More at STKAudioKit").onTapGesture {
                                if let url = URL(string: "https://www.audiokit.io/STKAudioKit/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }

                Group {
                    DisclosureGroup("Effects") {
                        Group {
                            NavigationLink("Auto Panner", destination: AutoPannerView())
                            NavigationLink("Auto Wah", destination: AutoWahView())
                            NavigationLink("Balancer", destination: BalancerView())
                            NavigationLink("Chorus", destination: ChorusView())
                            NavigationLink("Compressor", destination: CompressorView())
                            NavigationLink("Convolution", destination: ConvolutionView())
                            NavigationLink("Delay", destination: DelayView())
                            NavigationLink("Dynamic Range Compressor", destination: DynamicRangeCompressorView())
                            NavigationLink("Expander", destination: ExpanderView())
                        }
                        Group {
                            NavigationLink("Flanger", destination: FlangerView())
                            NavigationLink("MultiTap Delay", destination: MultiTapDelayView())
                            NavigationLink("Panner", destination: PannerView())
                            NavigationLink("Peak Limiter", destination: PeakLimiterView())
                            NavigationLink("Phaser", destination: PhaserView())
                            NavigationLink("Phase-Locked Vocoder", destination: PhaseLockedVocoderView())
                            NavigationLink("Playback Speed", destination: PlaybackSpeedView())
                            NavigationLink("Pitch Shifter", destination: PitchShifterView())
                            NavigationLink("Stereo Delay", destination: StereoDelayView())
                            NavigationLink("String Resonator", destination: StringResonatorView())
                        }
                        Group {
                            NavigationLink("Time / Pitch", destination: TimePitchView())
                            NavigationLink("Transient Shaper", destination: TransientShaperView())
                            NavigationLink("Tremolo", destination: TremoloView())
                            NavigationLink("Variable Delay", destination: VariableDelayView())
                        }
                    }
                }

                Group {
                    DisclosureGroup("Distortion") {
                        Group {
                            NavigationLink("Apple Distortion", destination: DistortionView())
                            NavigationLink("Bit Crusher", destination: BitCrusherView())
                            NavigationLink("Clipper", destination: ClipperView())
                            NavigationLink("Decimator", destination: DecimatorView())
                            NavigationLink("Ring Modulator", destination: RingModulatorView())
                            NavigationLink("Tanh Distortion", destination: TanhDistortionView())
                        }
                    }
                }

                Group {
                    DisclosureGroup("Reverb") {
                        Group {
                            NavigationLink("Apple Reverb", destination: ReverbView())
                            NavigationLink("Chowning Reverb", destination: ChowningReverbView())
                            NavigationLink("Comb Filter Reverb", destination: CombFilterReverbView())
                            NavigationLink("Costello Reverb", destination: CostelloReverbView())
                            NavigationLink("Flat Frequency Response Reverb",
                                           destination: FlatFrequencyResponseReverbView())
                            NavigationLink("Zita Reverb", destination: ZitaReverbView())
                        }
                    }
                }

                DisclosureGroup("Filters") {
                    Group {
                        NavigationLink("Band Pass Butterworth Filter",
                                       destination: BandPassButterworthFilterView())
                        NavigationLink("Band Reject Butterworth Filter",
                                       destination: BandRejectButterworthFilterView())
                        NavigationLink("Equalizer Filter", destination: EqualizerFilterView())
                        NavigationLink("Formant Filter", destination: FormantFilterView())
                        NavigationLink("High Pass Butterworth Filter",
                                       destination: HighPassButterworthFilterView())
                        NavigationLink("High Pass Filter", destination: HighPassFilterView())
                        NavigationLink("High Shelf Filter", destination: HighShelfFilterView())
                        NavigationLink("High Shelf Parametric Equalizer Filter",
                                       destination: HighShelfParametricEqualizerFilterView())
                        NavigationLink("Korg Low Pass Filter", destination: KorgLowPassFilterView())
                        NavigationLink("Low Pass Butterworth Filter",
                                       destination: LowPassButterworthFilterView())
                    }
                    Group {
                        NavigationLink("Low Pass Filter", destination: LowPassFilterView())
                        NavigationLink("Low Shelf Filter", destination: LowShelfFilterView())
                        NavigationLink("Low Shelf Parametric Equalizer Filter",
                                       destination: LowShelfParametricEqualizerFilterView())
                        NavigationLink("Modal Resonance Filter", destination: ModalResonanceFilterView())
                        NavigationLink("Moog Ladder", destination: MoogLadderView())
                        NavigationLink("Peaking Parametric Equalizer Filter",
                                       destination: PeakingParametricEqualizerFilterView())
                        NavigationLink("Resonant Filter", destination: ResonantFilterView())
                        NavigationLink("Three Pole Lowpass Filter", destination: ThreePoleLowpassFilterView())
                        NavigationLink("Tone Filter", destination: ToneFilterView())
                    }
                    Group {
                        NavigationLink("Tone Complement Filter", destination: ToneComplementFilterView())
                    }
                }

                Group {
                    DisclosureGroup("Oscillators") {
                        Group {
                            NavigationLink("Amplitude Envelope", destination: AmplitudeEnvelopeView())
                            NavigationLink("Dynamic Oscillator", destination: DynamicOscillatorView())
                            NavigationLink("FM Frequency Modulation", destination: FMOscillatorView())
                            NavigationLink("Phase Distortion", destination: PhaseDistortionOscillatorView())
                            NavigationLink("Pulse Width Modulation", destination: PWMOscillatorView())
                            NavigationLink("Sine", destination: OscillatorView())
                            NavigationLink("Waveform Morphing", destination: MorphingOscillatorView())
                        }
                    }

                    DisclosureGroup("Audio Player") {
                        Group {
                            NavigationLink("Completion Handler", destination: AudioPlayerCompletionHandler())
                            NavigationLink("Multi Segment Player", destination: MultiSegmentPlayerView())
                            NavigationLink("Playlist", destination: PlaylistView())
                        }
                    }

                    Group {
                        DisclosureGroup("Additional Packages") {
                            Group {
                                NavigationLink("Controls", destination: ControlsView())
                                NavigationLink("Flow", destination: FlowView())
                                NavigationLink("Keyboard", destination: KeyboardView())
                                NavigationLink("Piano Roll", destination: PianoRollView())
                                NavigationLink("Synthesis Toolkit", destination: STKView())
                                NavigationLink("Waveform", destination: WaveformView())
                            }
                        }
                    }

                    Group {
                        DisclosureGroup("Uncategorized Demos") {
                            Group {
                                NavigationLink("Audio Files View", destination: AudioFileRecipeView())
                                NavigationLink("Callback Instrument", destination: CallbackInstrumentView())
                                NavigationLink("Tables", destination: TableRecipeView())
                            }
                        }
                    }

                    DisclosureGroup("WIP") {
                        Group {
                            NavigationLink("Base Tap Demo", destination: BaseTapDemoView())
                            NavigationLink("Channel/Device Routing", destination: ChannelDeviceRoutingView())
                            NavigationLink("DunneAudioKit Synth", destination: DunneSynthView())
                            NavigationLink("Input Device Demo", destination: InputDeviceDemoView())
                            NavigationLink("MIDI Port Test", destination: MIDIPortTestView())
                            NavigationLink("Polyphonic Oscillator", destination: PolyphonicOscillatorView())
                            NavigationLink("Polyphonic STK + MIDIKit", destination: PolyphonicSTKView())
                            NavigationLink("Roland Tb303 Filter", destination: RolandTB303FilterView())
                        }
                    }
                }
            }
        }
        .navigationBarTitle("AudioKit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // This leading ToolbarItem is required to center the AudioKit logo on iPhones.
            ToolbarItem(placement: .topBarLeading) {
                Rectangle()
                    .frame(minWidth: 30)
                    .hidden()
                    .accessibilityHidden(true)
            }
            ToolbarItem(placement: .principal) {
                Image("audiokit-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("Learn about AudioKit")
            }
        }
        .sheet(isPresented: $showingInfo) {
            AudioKitInfoView()
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
                .frame(width: 300, height: 300)
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
