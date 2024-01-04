import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SporthAudioKit
import SwiftUI

class TelephoneConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()

    @Published var last10Digits = ""

    let dialTone = OperationGenerator {
        let dialTone1 = Operation.sineWave(frequency: 350)
        let dialTone2 = Operation.sineWave(frequency: 440)
        return mixer(dialTone1, dialTone2) * 0.3
    }

    //: ### Telephone Ringing
    //: The ringing sound is also a pair of frequencies that play for 2 seconds,
    //: and repeats every 6 seconds.
    let ringing = OperationGenerator {
        let ringingTone1 = Operation.sineWave(frequency: 480)
        let ringingTone2 = Operation.sineWave(frequency: 440)

        let ringingToneMix = mixer(ringingTone1, ringingTone2)

        let ringTrigger = Operation.metronome(frequency: 0.166_6) // 1 / 6 seconds

        let rings = ringingToneMix.triggeredWithEnvelope(
            trigger: ringTrigger,
            attack: 0.01, hold: 2, release: 0.01
        )

        return rings * 0.4
    }

    //: ### Busy Signal
    //: The busy signal is similar as well, just a different set of parameters.
    let busy = OperationGenerator {
        let busySignalTone1 = Operation.sineWave(frequency: 480)
        let busySignalTone2 = Operation.sineWave(frequency: 620)
        let busySignalTone = mixer(busySignalTone1, busySignalTone2)

        let busyTrigger = Operation.metronome(frequency: 2)
        let busySignal = busySignalTone.triggeredWithEnvelope(
            trigger: busyTrigger,
            attack: 0.01, hold: 0.25, release: 0.01
        )
        return busySignal * 0.4
    }

    //: ## Key presses
    //: All the digits are also just combinations of sine waves
    //:
    //: The canonical specification of DTMF Tones:
    var keys = [String: [Double]]()

    let keypad = OperationGenerator { _ in

        let keyPressTone = Operation.sineWave(frequency: Operation.parameters[1]) +
            Operation.sineWave(frequency: Operation.parameters[2])

        let momentaryPress = keyPressTone.triggeredWithEnvelope(
            trigger: Operation.parameters[0], attack: 0.01, hold: 0.1, release: 0.01
        )
        return momentaryPress * 0.4
    }

    func doit(key: String, state: String) {
        switch key {
        case "CALL":
            if state == "down" {
                busy.stop()
                dialTone.stop()
                if ringing.isStarted {
                    ringing.stop()
                    dialTone.start()
                } else {
                    ringing.start()
                }
            }

        case "BUSY":
            if state == "down" {
                ringing.stop()
                dialTone.stop()
                if busy.isStarted {
                    busy.stop()
                    dialTone.start()
                } else {
                    busy.start()
                }
            }

        default:
            if state == "down" {
                dialTone.stop()
                ringing.stop()
                busy.stop()
                keypad.parameter2 = AUValue(keys[key]![0])
                keypad.parameter3 = AUValue(keys[key]![1])
                keypad.parameter1 = 1
                last10Digits.append(key)
                if last10Digits.count > 10 {
                    last10Digits.removeFirst()
                }
            } else {
                keypad.parameter1 = 0
            }
        }
    }

    init() {
        keys["1"] = [697, 1209]
        keys["2"] = [697, 1336]
        keys["3"] = [697, 1477]
        keys["4"] = [770, 1209]
        keys["5"] = [770, 1336]
        keys["6"] = [770, 1477]
        keys["7"] = [852, 1209]
        keys["8"] = [852, 1336]
        keys["9"] = [852, 1477]
        keys["*"] = [941, 1209]
        keys["0"] = [941, 1336]
        keys["#"] = [941, 1477]

        keypad.start()
        engine.output = Mixer(dialTone, ringing, busy, keypad)
    }
}

struct Phone: View {
    @StateObject var conductor: TelephoneConductor
    @State var currentDigit = ""

    func NumberKey(mainDigit: String, alphanumerics: String = "") -> some View {
        let stack = ZStack {
            Circle().foregroundColor(Color(.sRGB, red: 0.5, green: 0.5, blue: 0.5, opacity: 0.4))
            VStack {
                Text(mainDigit).font(.largeTitle)
                Text(alphanumerics)
            }
        }.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { _ in
            if currentDigit != mainDigit {
                conductor.doit(key: mainDigit, state: "down")
                currentDigit = mainDigit
            }
        }.onEnded { _ in
            conductor.doit(key: mainDigit, state: "up")
            currentDigit = ""
        })

        let stack2 = ZStack {
            stack.colorInvert().opacity(mainDigit == currentDigit ? 1 : 0)
            stack.opacity(mainDigit == currentDigit ? 0 : 1)
        }

        return stack2
    }

    func PhoneKey() -> some View {
        return ZStack {
            Circle().foregroundColor(.green).opacity(0.8)
            Image(systemName: "phone.fill").font(.largeTitle)
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { _ in
            if conductor.last10Digits.count > 0 {
                conductor.doit(key: "CALL", state: "down")
            }
        }.onEnded { _ in
            conductor.doit(key: "CALL", state: "up")
        })
    }

    func BusyKey() -> some View {
        return ZStack {
            Circle().foregroundColor(.red).opacity(0.8)
            Image(systemName: "phone.down.fill").font(.largeTitle)
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { _ in
            conductor.doit(key: "BUSY", state: "down")
        }.onEnded { _ in
            conductor.doit(key: "BUSY", state: "up")
        })
    }

    func DeleteKey() -> some View {
        return ZStack {
            Circle().foregroundColor(.blue).opacity(0.8)
            Image(systemName: "delete.left.fill").font(.largeTitle)
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { _ in
            if conductor.last10Digits.count > 0 {
                conductor.last10Digits.removeLast()
            }
        })
    }

    var body: some View {
        VStack {
            Text(formattedPhoneNumber(conductor.last10Digits))
                .font(.largeTitle)

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    NumberKey(mainDigit: "1")
                    NumberKey(mainDigit: "2", alphanumerics: "A B C")
                    NumberKey(mainDigit: "3", alphanumerics: "D E F")
                }
                HStack(spacing: 20) {
                    NumberKey(mainDigit: "4", alphanumerics: "G H I")
                    NumberKey(mainDigit: "5", alphanumerics: "J K L")
                    NumberKey(mainDigit: "6", alphanumerics: "M N O")
                }
                HStack(spacing: 20) {
                    NumberKey(mainDigit: "7", alphanumerics: "P Q R S")
                    NumberKey(mainDigit: "8", alphanumerics: "T U V")
                    NumberKey(mainDigit: "9", alphanumerics: "W X Y Z")
                }
                HStack(spacing: 20) {
                    NumberKey(mainDigit: "*")
                    NumberKey(mainDigit: "0")
                    NumberKey(mainDigit: "#")
                }
                HStack(spacing: 20) {
                    BusyKey()
                    PhoneKey()
                    DeleteKey()
                }
            }.padding(30)
        }
        .padding()
    }

    // MARK: - Phone - Private

    private func formattedPhoneNumber(_ digits: String) -> String {
        return digits == "" ? " " : digits
    }
}

struct Telephone: View {
    var conductor = TelephoneConductor()
    var body: some View {
        Phone(conductor: conductor)
            .cookbookNavBarTitle("Telephone")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
    }
}
