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
        List {
            Section(header: Text("Analysis")) {
                NavigationLink(destination: TunerView()) { Text("Tuner") }
            }
            Section(header: Text("Effects")) {
                NavigationLink(destination: AutoWahView()) { Text("Auto Wah") }
                NavigationLink(destination: BitCrusherView()) { Text("Bit Crusher") }
                NavigationLink(destination: CostelloReverbView()) { Text("Costello Reverb") }
                NavigationLink(destination: DelayView()) { Text("Delay") }
                NavigationLink(destination: FlatFrequencyResponseReverbView()) { Text("Flat Frequency Response Reverb") }
            }
            Section(header: Text("Filters")) {
                NavigationLink(destination: BandPassButterworthFilterView()) { Text("Band Pass Butterworth Filter") }
                NavigationLink(destination: BandRejectButterworthFilterView()) { Text("Band Reject Butterworth Filter") }
                NavigationLink(destination: HighPassButterworthFilterView()) { Text("High Pass Butterworth Filter") }
                NavigationLink(destination: KorgLowPassFilterView()) { Text("Korg Low Pass Filter") }
                NavigationLink(destination: LowPassButterworthFilterView()) { Text("Low Pass Butterworth Filter") }
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
            Section(header: Text("Other Generators")) {
                NavigationLink(destination: DrumsView()) { Text("Drum Pads") }
                NavigationLink(destination: NoiseGeneratorsView()) { Text("Noise Generators") }
                NavigationLink(destination: Telephone()) { Text("Telephone") }
                NavigationLink(destination: VocalTractView()) { Text("Vocal Tract") }
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
