import AudioKit
import AudioKitUI
import SwiftUI

struct KeyboardControl: View {
    @State var firstOctave: Int
    @State var octaveCount: Int
    @State var polyphonicMode: Bool
    weak var delegate: KeyboardDelegate?
    var body: some View {
        HStack {
            VStack {
                Text("First Octave")
                    .fontWeight(.bold)
                HStack {
                    Button(
                    action: {
                        guard firstOctave > -2 else { return }
                        firstOctave -= 1
                    },
                    label: {
                        Text("-")
                    })
                    Text("\(firstOctave)")
                    Button(
                    action: {
                        guard firstOctave < 8 else { return }
                        firstOctave += 1
                    },
                    label: {
                        Text("+")
                    })
                }
            }
            .padding()
            VStack {
                Text("Octave Count")
                    .fontWeight(.bold)
                HStack {
                    Button(
                    action: {
                        guard octaveCount > 1 else { return }
                        octaveCount -= 1
                    },
                    label: {
                        Text("-")
                    })
                    Text("\(octaveCount)")
                    Button(
                    action: {
                        guard octaveCount < 10 else { return }
                        octaveCount += 1
                    },
                    label: {
                        Text("+")
                    })
                }
            }
            .padding()
            VStack {
                Text("Polyphonic Mode")
                    .fontWeight(.bold)
                HStack {
                    Button(
                    action: {
                        polyphonicMode.toggle()
                    },
                    label: {
                        Text("Toggle:")
                    })
                    if polyphonicMode {
                        Text("ON")
                    } else {
                        Text("OFF")
                    }
                }
            }
        }
        KeyboardWidget(delegate: delegate,
                       firstOctave: firstOctave,
                       octaveCount: octaveCount,
                       polyphonicMode: polyphonicMode)
    }
}
