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

struct MIDIKitKeyboard: View {
    var noteOn: (Pitch, CGPoint) -> Void = { _, _ in }
    var noteOff: (Pitch) -> Void
    var body: some View {
        Keyboard(layout: .piano(pitchRange: Pitch(48) ... Pitch(64)),
                 noteOn: noteOn, noteOff: noteOff){ pitch, isActivated in
            MIDIKitKeyboardKey(pitch: pitch,
                                isActivated: isActivated, color: .red)
        }.cornerRadius(5)
    }
}

struct MIDIKitKeyboardKey: View {
    @State var MIDIKeyPressed = [Bool](repeating: false, count: 128)
    var pitch : Pitch
    var isActivated : Bool
    var color: Color
    
    var body: some View {
        VStack{
            KeyboardKey(pitch: pitch,
                        isActivated: isActivated,
                        text: "",
                        whiteKeyColor: .white,
                        blackKeyColor: .black,
                        pressedColor:  color,
                        flatTop: true,
                        isActivatedExternally: MIDIKeyPressed[pitch.intValue])
        }.onReceive(NotificationCenter.default.publisher(for: .MIDIKey), perform: { obj in
            if let userInfo = obj.userInfo, let info = userInfo["info"] as? UInt8, let val = userInfo["bool"] as? Bool {
                self.MIDIKeyPressed[Int(info)] = val
            }
        })
    }
}
