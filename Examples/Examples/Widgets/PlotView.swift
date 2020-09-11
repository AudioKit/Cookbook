import AudioKit
import SwiftUI
import AVFoundation

protocol ProcessesPlayerInput {
    var player: AKPlayer { get }
}

struct PlayerControls: View {
    var conductor: ProcessesPlayerInput
    @State var isPlaying = false

    var body: some View {
        HStack {
            Text("Playback: ")
            Image(systemName: isPlaying ? "stop" : "play" ).onTapGesture {
                self.isPlaying ? self.conductor.player.pause() : self.conductor.player.play()
                self.isPlaying.toggle()
            }
        }
    }
}


struct DryWetMixPlotsView: View {
    var dry: AKNodeOutputPlot
    var wet: AKNodeOutputPlot
    var mix: AKNodeOutputPlot

    var height: CGFloat = 100

    func plot(_ plot: AKNodeOutputPlot, label: String) -> some View {
        VStack {
            HStack { Text(label); Spacer() }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.init(hue: 0, saturation: 0, brightness: 0.5, opacity: 0.2))
                    .frame(height: height)
                PlotView(view: plot).frame(height: height).clipped()
            }
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            plot(dry, label: "Input")
            plot(wet, label: "Processed Signal")
            plot(mix, label: "Mixed Output")
        }
    }
}


struct PlotView: UIViewRepresentable {
    typealias UIViewType = AKNodeOutputPlot
    var view: AKNodeOutputPlot

    func makeUIView(context: Context) -> AKNodeOutputPlot {
        view.backgroundColor = UIColor.clear //UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 0.2)
        return view
    }

    func updateUIView(_ uiView: AKNodeOutputPlot, context: Context) {
        //
    }

}

struct FFTPlotView: UIViewRepresentable {

    typealias UIViewType = AKNodeFFTPlot
    var view: AKNodeFFTPlot

    func makeUIView(context: Context) -> AKNodeFFTPlot {
        view.backgroundColor = .systemBackground
        return view
    }

    func updateUIView(_ uiView: AKNodeFFTPlot, context: Context) {
        //
    }

}

struct TelephoneView: UIViewRepresentable {

    typealias UIViewType = AKTelephoneView
    var callback: (String, String) -> Void

    func makeUIView(context: Context) -> AKTelephoneView {
        let view = AKTelephoneView(callback: callback)
        view.backgroundColor = .systemBackground
        return view
    }

    func updateUIView(_ uiView: AKTelephoneView, context: Context) {
        //
    }

}

struct ADSRView: UIViewRepresentable {

    typealias UIViewType = AKADSRView
    var callback: (AUValue, AUValue, AUValue, AUValue) -> Void

    func makeUIView(context: Context) -> AKADSRView {
        let view = AKADSRView(callback: callback)
        view.bgColor = .systemBackground
        return view
    }

    func updateUIView(_ uiView: AKADSRView, context: Context) {
        //
    }

}
