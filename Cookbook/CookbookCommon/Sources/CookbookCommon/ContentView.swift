import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            MasterView()
//            DetailView()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MasterView: View {
    var body: some View {
        Form {
            Section(header: Text("Categories")) {
                Group {
                    DisclosureGroup("Mini Apps") {
                        Group {
                            NavigationLink("Drum Pads", destination: DrumsView())
                            NavigationLink("Drum Sequencer", destination: DrumSequencerView())
                            NavigationLink("Drum Synthesizers", destination: DrumSynthesizersView())
                            NavigationLink("Graphic Equalizer", destination: GraphicEqualizerView())
                            NavigationLink("Instrument EXS", destination: InstrumentEXSView())
                            NavigationLink("Instrument SFZ", destination: InstrumentSFZView())
                        }
                        Group {
                            NavigationLink("Music Toy", destination: MusicToyView())
                            NavigationLink("Telephone", destination: Telephone())
                            NavigationLink("Tuner", destination: TunerView())
                            NavigationLink("Noise Generators", destination: NoiseGeneratorsView())
                            NavigationLink("Vocal Tract", destination: VocalTractView())
                            NavigationLink("MIDI Monitor", destination: MIDIMonitorView())
                            NavigationLink("MIDI Track View", destination: MIDITrackDemo())
                            NavigationLink("Recorder", destination: RecorderView())
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
                            NavigationLink("Callback Instrument", destination: CallbackInstrumentView())
                            NavigationLink("Tables", destination: TableRecipeView())
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
							NavigationLink("Audio3D", destination: AudioKit3DView())
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
                            NavigationLink("String Resonator", destination: StringResonatorView())
                            NavigationLink("Time / Pitch", destination: TimePitchView())
                        }
                        Group {
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
                            NavigationLink("Chowning Reverb", destination: ChowningReverbView())
                            NavigationLink("Comb Filter Reverb", destination: CombFilterReverbView())
                            NavigationLink("Costello Reverb", destination: CostelloReverbView())
                            NavigationLink("Flat Frequency Response Reverb",
                                destination: FlatFrequencyResponseReverbView())
                            NavigationLink("Apple Reverb", destination: ReverbView())
                            NavigationLink("Zita Reverb", destination: ZitaReverbView())
                        }
                    }
                }
                Group {
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

                    DisclosureGroup("Oscillators") {
                        Group {
                            NavigationLink("Amplitude Envelope", destination: AmplitudeEnvelopeView())
                            NavigationLink("Dynamic Oscillator", destination: DynamicOscillatorView())
                            NavigationLink("FM Frequency Modulation", destination: FMOscillatorView())
                            NavigationLink("Waveform Morphing", destination: MorphingOscillatorView())
                            NavigationLink("Sine", destination: OscillatorView())
                            NavigationLink("Phase Distortion", destination: PhaseDistortionOscillatorView())
                            NavigationLink("Pulse Width Modulation", destination: PWMOscillatorView())
                        }
                    }

                    DisclosureGroup("Audio Player") {
                        Group {
                            NavigationLink("Completion Handler", destination: AudioPlayerCompletionHandler())
                            NavigationLink("Multi Segment Player", destination: MultiSegmentPlayerView())
                            NavigationLink("Playlist", destination: PlaylistView())
                        }
                    }

                    DisclosureGroup("WIP") {
                        Group {
                            NavigationLink("Base Tap Demo", destination: BaseTapDemoView())
                            NavigationLink("Channel/Device Routing", destination: ChannelDeviceRoutingView())
                            NavigationLink("MIDI Port Test", destination: MIDIPortTestView())
                            NavigationLink("Polyphonic Oscillator", destination: PolyphonicOscillatorView())
                            NavigationLink("Roland Tb303 Filter", destination: RolandTB303FilterView())
                        }
                    }
                }
            }
        }
        .navigationBarTitle("AudioKit")
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
