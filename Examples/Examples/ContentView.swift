import SwiftUI
import AVFoundation
import AudioKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

struct ContentView: View {
    @State private var dates = [Date]()

    var body: some View {
        NavigationView {
            MasterView()
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ParameterSlider: View {
    var text: String
    var parameter: Binding<AUValue>
    var range: ClosedRange<AUValue>

    var body: some View {
        GeometryReader { gp in
            HStack  {
                Spacer()
                Text(self.text).frame(width: gp.size.width * 0.2)
                Slider(value: self.parameter, in: self.range).frame(width: gp.size.width / 2)
                Text("\(self.parameter.wrappedValue)").frame(width: gp.size.width * 0.2)
                Spacer()
            }
        }
    }
}

struct KeyboardView: UIViewRepresentable {

    typealias UIViewType = AKKeyboardView
    var delegate: AKKeyboardDelegate

    func makeUIView(context: Context) -> AKKeyboardView {
        let view = AKKeyboardView(width: 0, height: 0)
        view.delegate = delegate
        view.firstOctave = 2
        return view
    }

    func updateUIView(_ uiView: AKKeyboardView, context: Context) {
        //
    }

}

struct PlotView: UIViewRepresentable {

    typealias UIViewType = AKNodeOutputPlot2
    var view: AKNodeOutputPlot2

    func makeUIView(context: Context) -> AKNodeOutputPlot2 {
        return view
    }

    func updateUIView(_ uiView: AKNodeOutputPlot2, context: Context) {
        //
    }

}



struct MasterView: View {

    var body: some View {
        List {
            Section(header: Text("Oscillators")) {
                NavigationLink(destination: FMOscillatorView()) { Text("FM Oscillator") }
                NavigationLink(destination: MorphingOscillatorView()) { Text("Morphing Oscillator") }
                NavigationLink(destination: OscillatorView()) { Text("Oscillator") }
                NavigationLink(destination: PhaseDistortionOscillatorView()) { Text("Phase Distortion Oscillator") }
                NavigationLink(destination: PWMOscillatorView()) { Text("PWM Oscillator") }
            }
            Section(header: Text("Other Generators")) {
                NavigationLink(destination: DrumsView()) { Text("Drums") }
                NavigationLink(destination: NoiseGeneratorsView()) { Text("Noise Generators") }
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
