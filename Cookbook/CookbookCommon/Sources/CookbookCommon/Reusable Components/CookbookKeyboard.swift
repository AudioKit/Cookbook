import AudioKit
import SwiftUI
import Keyboard
import Tonic

struct CookbookKeyboard: View {
    var noteOn: (Pitch, CGPoint) -> Void = { _, _ in }
    var noteOff: (Pitch) -> Void
    var body: some View {
        Keyboard(layout: .piano(pitchRange: Pitch(48) ... Pitch(64)),
                 noteOn: noteOn, noteOff: noteOff)
    }
}
