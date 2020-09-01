import SwiftUI
import AudioKit

struct KeyboardView: UIViewRepresentable {

    typealias UIViewType = AKKeyboardView
    var delegate: AKKeyboardDelegate?

    func makeUIView(context: Context) -> AKKeyboardView {
        let view = AKKeyboardView(width: 0, height: 0)
        view.delegate = delegate
        view.firstOctave = 2
        view.octaveCount = 2
        return view
    }

    func updateUIView(_ uiView: AKKeyboardView, context: Context) {
        //
    }

}
struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KeyboardView(delegate: nil).previewLayout(PreviewLayout.fixed(width: 500, height: 200))
                .padding()
                .previewDisplayName("Light Mode")

            KeyboardView(delegate: nil).previewLayout(PreviewLayout.fixed(width: 500, height: 200))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}



