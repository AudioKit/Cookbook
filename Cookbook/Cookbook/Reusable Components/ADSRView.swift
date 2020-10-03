import AudioKit
import SwiftUI
import AVFoundation

struct ADSRWidget: UIViewRepresentable {

    typealias UIViewType = ADSRView
    var callback: (AUValue, AUValue, AUValue, AUValue) -> Void

    func makeUIView(context: Context) -> ADSRView {
        let view = ADSRView(callback: callback)
        view.bgColor = .systemBackground
        return view
    }

    func updateUIView(_ uiView: ADSRView, context: Context) {
        //
    }

}
