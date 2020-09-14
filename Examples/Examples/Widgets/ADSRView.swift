import AudioKit
import SwiftUI
import AVFoundation

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
