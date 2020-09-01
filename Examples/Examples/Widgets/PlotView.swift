import AudioKit
import SwiftUI

struct PlotView: UIViewRepresentable {

    typealias UIViewType = AKNodeOutputPlot
    var view: AKNodeOutputPlot

    func makeUIView(context: Context) -> AKNodeOutputPlot {
        view.backgroundColor = .systemBackground
        return view
    }

    func updateUIView(_ uiView: AKNodeOutputPlot, context: Context) {
        //
    }

}
