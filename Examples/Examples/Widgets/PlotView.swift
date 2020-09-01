import AudioKit
import SwiftUI
import AVFoundation

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
