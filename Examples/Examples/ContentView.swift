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
            Section(header: Text("Oscillators")) {
                NavigationLink(destination: FMOscillatorView()) { Text("FM Frequency Modulation") }
                NavigationLink(destination: MorphingOscillatorView()) { Text("Waveform Morphing") }
                NavigationLink(destination: OscillatorView()) { Text("Sine") }
                NavigationLink(destination: PhaseDistortionOscillatorView()) { Text("Phase Distortion ") }
                NavigationLink(destination: PWMOscillatorView()) { Text("Pulse Width Modulation") }
            }
            Section(header: Text("Other Generators")) {
                NavigationLink(destination: DrumsView()) { Text("Drum Pads") }
                NavigationLink(destination: NoiseGeneratorsView()) { Text("Noise Generators") }
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
