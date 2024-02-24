import Keyboard
import SwiftUI
import Tonic

let evenSpacingInitialSpacerRatio: [Letter: CGFloat] = [
    .C: 0.0,
    .D: 2.0 / 12.0,
    .E: 4.0 / 12.0,
    .F: 0.0 / 12.0,
    .G: 1.0 / 12.0,
    .A: 3.0 / 12.0,
    .B: 5.0 / 12.0
]

let evenSpacingSpacerRatio: [Letter: CGFloat] = [
    .C: 7.0 / 12.0,
    .D: 7.0 / 12.0,
    .E: 7.0 / 12.0,
    .F: 7.0 / 12.0,
    .G: 7.0 / 12.0,
    .A: 7.0 / 12.0,
    .B: 7.0 / 12.0
]

let evenSpacingRelativeBlackKeyWidth: CGFloat = 7.0 / 12.0

struct KeyboardView: View {

    func noteOn(pitch: Pitch, point: CGPoint) {
        print("note on \(pitch)")
    }

    func noteOff(pitch: Pitch) {
        print("note off \(pitch)")
    }

    func noteOnWithVerticalVelocity(pitch: Pitch, point: CGPoint) {
        print("note on \(pitch), midiVelocity: \(Int(point.y * 127))")
    }

    func noteOnWithReversedVerticalVelocity(pitch: Pitch, point: CGPoint) {
        print("note on \(pitch), midiVelocity: \(Int((1.0 - point.y) * 127))")
    }

    var randomColors: [Color] = (0 ... 12).map { _ in
        Color(red: Double.random(in: 0 ... 1),
              green: Double.random(in: 0 ... 1),
              blue: Double.random(in: 0 ... 1), opacity: 1)
    }

    @State var lowNote = 24
    @State var highNote = 48

    @State var scaleIndex = Scale.allCases.firstIndex(of: .chromatic) ?? 0 {
        didSet {
            if scaleIndex >= Scale.allCases.count { scaleIndex = 0 }
            if scaleIndex < 0 { scaleIndex = Scale.allCases.count - 1 }
            scale = Scale.allCases[scaleIndex]
        }
    }

    @State var scale: Scale = .chromatic
    @State var root: NoteClass = .C
    @State var rootIndex = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Keyboard(layout: .verticalIsomorphic(pitchRange: Pitch(48) ... Pitch(77))).frame(width: 100)
            VStack {
                HStack {
                    Stepper("Lowest Note: \(Pitch(intValue: lowNote).note(in: .C).description)",
                            onIncrement: {
                                if lowNote < 126, highNote > lowNote + 12 {
                                    lowNote += 1
                                }
                            },
                            onDecrement: {
                                if lowNote > 0 {
                                    lowNote -= 1
                                }
                            })
                    Stepper("Highest Note: \(Pitch(intValue: highNote).note(in: .C).description)",
                            onIncrement: {
                                if highNote < 126 {
                                    highNote += 1
                                }
                            },
                            onDecrement: {
                                if highNote > 1, highNote > lowNote + 12 {
                                    highNote -= 1
                                }

                            })
                }
                Keyboard(layout: .piano(pitchRange: Pitch(intValue: lowNote) ... Pitch(intValue: highNote)),
                         noteOn: noteOnWithVerticalVelocity(pitch:point:), noteOff: noteOff)
                .frame(minWidth: 100, minHeight: 100)

                HStack {
                    Stepper("Root: \(root.description)",
                            onIncrement: {
                        let allSharpNotes = (0...11).map { Note(pitch: Pitch(intValue: $0)).noteClass }
                        var index = allSharpNotes.firstIndex(of: root.canonicalNote.noteClass) ?? 0
                        index += 1
                        if index > 11 { index = 0}
                        if index < 0 { index = 1}
                        rootIndex = index
                        root = allSharpNotes[index]
                    },
                            onDecrement: {
                        let allSharpNotes = (0...11).map { Note(pitch: Pitch(intValue: $0)).noteClass }
                        var index = allSharpNotes.firstIndex(of: root.canonicalNote.noteClass) ?? 0
                        index -= 1
                        if index > 11 { index = 0}
                        if index < 0 { index = 1}
                        rootIndex = index
                        root = allSharpNotes[index]
                    })

                    Stepper("Scale: \(scale.description)",
                            onIncrement: { scaleIndex += 1 },
                            onDecrement: { scaleIndex -= 1 })
                }
                Keyboard(layout: .isomorphic(pitchRange:
                                                Pitch(intValue: 12 + rootIndex) ... Pitch(intValue: 84 + rootIndex),
                                             root: root,
                                             scale: scale),
                         noteOn: noteOnWithReversedVerticalVelocity(pitch:point:), noteOff: noteOff)
                .frame(minWidth: 100, minHeight: 100)

                Keyboard(layout: .guitar(),
                         noteOn: noteOn, noteOff: noteOff) { pitch, isActivated in
                    KeyboardKey(pitch: pitch,
                                isActivated: isActivated,
                                text: pitch.note(in: .F).description,
                                pressedColor: Color(PitchColor.newtonian[Int(pitch.pitchClass)]),
                                alignment: .center)
                }
                .frame(minWidth: 100, minHeight: 100)

                Keyboard(layout: .isomorphic(pitchRange: Pitch(48) ... Pitch(65))) { pitch, isActivated in
                    KeyboardKey(pitch: pitch,
                                isActivated: isActivated,
                                text: pitch.note(in: .F).description,
                                pressedColor: Color(PitchColor.newtonian[Int(pitch.pitchClass)]))
                }
                .frame(minWidth: 100, minHeight: 100)

                Keyboard(latching: true, noteOn: noteOn, noteOff: noteOff) { pitch, isActivated in
                    if isActivated {
                        ZStack {
                            Rectangle().foregroundColor(.black)
                            VStack {
                                Spacer()
                                Text(pitch.note(in: .C).description).font(.largeTitle)
                            }.padding()
                        }

                    } else {
                        Rectangle().foregroundColor(randomColors[Int(pitch.intValue) % 12])
                    }
                }
                .frame(minWidth: 100, minHeight: 100)
            }
            Keyboard(
                layout: .verticalPiano(pitchRange: Pitch(48) ... Pitch(77),
                                       initialSpacerRatio: evenSpacingInitialSpacerRatio,
                                       spacerRatio: evenSpacingSpacerRatio,
                                       relativeBlackKeyWidth: evenSpacingRelativeBlackKeyWidth)
            ).frame(width: 100)
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
        .navigationTitle("Keyboard Demo")
    }
}
