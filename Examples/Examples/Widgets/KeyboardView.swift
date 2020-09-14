import SwiftUI
import AudioKit

struct KeyboardView: UIViewRepresentable {

    var firstOctave = 2
    var octaveCount = 2
    
    typealias UIViewType = AKKeyboardView
    var delegate: AKKeyboardDelegate?

    func makeUIView(context: Context) -> AKKeyboardView {
        let view = AKKeyboardView()
        view.delegate = delegate
        view.firstOctave = firstOctave
        view.octaveCount = octaveCount
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



