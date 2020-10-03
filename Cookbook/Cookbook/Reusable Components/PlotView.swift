import AudioKit
import SwiftUI
import AVFoundation

struct DryWetMixPlotsView: View {
    var dry: NodeOutputPlot
    var wet: NodeOutputPlot
    var mix: NodeOutputPlot

    var height: CGFloat = 100

    func plot(_ plot: NodeOutputPlot, label: String) -> some View {
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

struct DryWetMixFFTPlotsView: View {
    var dry: NodeFFTPlot
    var wet: NodeFFTPlot
    var mix: NodeFFTPlot

    var height: CGFloat = 100

    func plot(_ plot: NodeFFTPlot, label: String) -> some View {
        VStack {
            HStack { Text(label); Spacer() }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(hue: 0, saturation: 0, brightness: 0.5, opacity: 0.2))
                    .frame(height: height)
                FFTPlotView(view: plot).frame(height: height).clipped()
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
    typealias UIViewType = NodeOutputPlot
    var view: NodeOutputPlot

    func makeUIView(context: Context) -> NodeOutputPlot {
        view.backgroundColor = UIColor.clear //UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 0.2)
        return view
    }

    func updateUIView(_ uiView: NodeOutputPlot, context: Context) {
        //
    }

}

struct FFTPlotView: UIViewRepresentable {

    typealias UIViewType = NodeFFTPlot
    var view: NodeFFTPlot

    func makeUIView(context: Context) -> NodeFFTPlot {
        view.backgroundColor = .systemBackground
        return view
    }

    func updateUIView(_ uiView: NodeFFTPlot, context: Context) {
        //
    }

}
