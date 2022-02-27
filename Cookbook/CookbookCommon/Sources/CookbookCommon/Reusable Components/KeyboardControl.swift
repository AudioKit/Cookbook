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
                    Button("-", action: decreaseFirstOctave)
                    Text("\(firstOctave)")
                    Button("+", action: increaseFirstOctave)
                }
            }
            .padding()
            VStack {
                Text("Octave Count")
                    .fontWeight(.bold)
                HStack {
                    Button("-", action: decreaseOctaveCount)
                    Text("\(octaveCount)")
                    Button("+", action: increaseOctaveCount)
                }
            }
            .padding()
            VStack {
                Text("Polyphonic Mode")
                    .fontWeight(.bold)
                HStack {
                    Button("Toggle:") { polyphonicMode.toggle() }
                    polyphonicMode ? Text("ON") : Text("OFF")
                }
            }
        }
        KeyboardWidget(delegate: delegate,
                       firstOctave: firstOctave,
                       octaveCount: octaveCount,
                       polyphonicMode: polyphonicMode)
    }

    private func decreaseFirstOctave() {
        // Negative value error occurs when firstOctave < -2.
        guard firstOctave > -2 else { return }
        firstOctave -= 1
    }

    private func increaseFirstOctave() {
        // A very high firstOctave value will crash the app.
        guard firstOctave < 8 else { return }
        firstOctave += 1
    }

    private func decreaseOctaveCount() {
        // Division by zero error occurs when octaveCount is 0.
        guard octaveCount > 1 else { return }
        octaveCount -= 1
    }

    private func increaseOctaveCount() {
        // A very high octaveCount value will crash the app.
        guard octaveCount < 10 else { return }
        octaveCount += 1
    }
}
