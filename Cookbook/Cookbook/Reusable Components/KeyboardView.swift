import SwiftUI
import AudioKit

struct KeyboardWidget: UIViewRepresentable {

    var firstOctave = 2
    var octaveCount = 2

    typealias UIViewType = KeyboardView
    var delegate: KeyboardDelegate?

    func makeUIView(context: Context) -> KeyboardView {
        let view = KeyboardView()
        view.delegate = delegate
        view.firstOctave = firstOctave
        view.octaveCount = octaveCount
        return view
    }

    func updateUIView(_ uiView: KeyboardView, context: Context) {
        //
    }

}
struct KeyboardWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KeyboardWidget(delegate: nil).previewLayout(PreviewLayout.fixed(width: 500, height: 200))
                .padding()
                .previewDisplayName("Light Mode")

            KeyboardWidget(delegate: nil).previewLayout(PreviewLayout.fixed(width: 500, height: 200))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
