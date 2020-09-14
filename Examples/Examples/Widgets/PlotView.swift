import AudioKit
import SwiftUI
import AVFoundation


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

class WaveformUIView: UIView {
    var waveform: AKWaveform
    var table: [Float] = [] {
        didSet {
            waveform.fill(with: [table])
        }
    }

    public init(_ table: [Float], frame: CGRect = CGRect(x: 0, y: 0, width: 440, height: 150)) {
        self.table = table
        waveform = AKWaveform(channels: 1, size: frame.size, waveformColor: UIColor.red.cgColor, backgroundColor: UIColor.black.cgColor)
        waveform.fill(with: [table])
        super.init(frame: frame)
        layer.addSublayer(waveform)
        layer.setNeedsDisplay()
    }

    /// Required initializer
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct WaveformView: UIViewRepresentable {

    typealias UIViewType = WaveformUIView
    var view: WaveformUIView

    func makeUIView(context: Context) -> WaveformUIView {
        view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 0.5)
        return view
    }

    func updateUIView(_ uiView: WaveformUIView, context: Context) {
        //
    }

}


