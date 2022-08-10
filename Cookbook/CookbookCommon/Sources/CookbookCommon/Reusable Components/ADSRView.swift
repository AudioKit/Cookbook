import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

struct ADSRWidget: UIViewRepresentable {
    typealias UIViewType = ADSRView
    var callback: (AUValue, AUValue, AUValue, AUValue) -> Void

    func makeUIView(context _: Context) -> ADSRView {
        let view = ADSRView(callback: callback)
        view.bgColor = .systemBackground
        return view
    }

    func updateUIView(_: ADSRView, context _: Context) {
        //
    }
}
