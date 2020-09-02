import AudioKit
import AVFoundation
import SwiftUI

class TelephoneConductor: Conductor, ObservableObject {

    let engine = AKEngine()

    let dialTone = AKOperationGenerator {
         let dialTone1 = AKOperation.sineWave(frequency: 350)
         let dialTone2 = AKOperation.sineWave(frequency: 440)
         return mixer(dialTone1, dialTone2) * 0.3
     }

     //: ### Telephone Ringing
     //: The ringing sound is also a pair of frequencies that play for 2 seconds,
     //: and repeats every 6 seconds.
     let ringing = AKOperationGenerator {
         let ringingTone1 = AKOperation.sineWave(frequency: 480)
         let ringingTone2 = AKOperation.sineWave(frequency: 440)

         let ringingToneMix = mixer(ringingTone1, ringingTone2)

         let ringTrigger = AKOperation.metronome(frequency: 0.166_6) // 1 / 6 seconds

         let rings = ringingToneMix.triggeredWithEnvelope(
             trigger: ringTrigger,
             attack: 0.01, hold: 2, release: 0.01)

         return rings * 0.4
     }

     //: ### Busy Signal
     //: The busy signal is similar as well, just a different set of parameters.
     let busy = AKOperationGenerator {
         let busySignalTone1 = AKOperation.sineWave(frequency: 480)
         let busySignalTone2 = AKOperation.sineWave(frequency: 620)
         let busySignalTone = mixer(busySignalTone1, busySignalTone2)

         let busyTrigger = AKOperation.metronome(frequency: 2)
         let busySignal = busySignalTone.triggeredWithEnvelope(
             trigger: busyTrigger,
             attack: 0.01, hold: 0.25, release: 0.01)
         return busySignal * 0.4
     }
     //: ## Key presses
     //: All the digits are also just combinations of sine waves
     //:
     //: The canonical specification of DTMF Tones:
     var keys = [String: [Double]]()


     let keypad = AKOperationGenerator { parameters in

         let keyPressTone = AKOperation.sineWave(frequency: AKOperation.parameters[1]) +
             AKOperation.sineWave(frequency: AKOperation.parameters[2])

         let momentaryPress = keyPressTone.triggeredWithEnvelope(
             trigger: AKOperation.parameters[0], attack: 0.01, hold: 0.1, release: 0.01)
         return momentaryPress * 0.4
     }

    lazy var callback: (String, String) -> Void = {x, y in self.doit(key: x, state: y) }

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
            } else {
                keypad.parameter1 = 0
            }
        }
    }
    func start() {


        keys["1"] = [697, 1_209]
        keys["2"] = [697, 1_336]
        keys["3"] = [697, 1_477]
        keys["4"] = [770, 1_209]
        keys["5"] = [770, 1_336]
        keys["6"] = [770, 1_477]
        keys["7"] = [852, 1_209]
        keys["8"] = [852, 1_336]
        keys["9"] = [852, 1_477]
        keys["*"] = [941, 1_209]
        keys["0"] = [941, 1_336]
        keys["#"] = [941, 1_477]

        keypad.start()

        engine.output = AKMixer(dialTone, ringing, busy, keypad)


        do {
            try engine.start()
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        engine.stop()

        // Need to ensure the mixer we created in start() is
        // deallocated before start() is invoked again.
        engine.output = nil
    }
}

struct Telephone: View {
    var conductor = TelephoneConductor()
    var body: some View {
        // TODO REcreate in SwiftUI
        TelephoneView(callback: conductor.callback)
        .padding()
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Telephone_Previews: PreviewProvider {
    static var conductor = TelephoneConductor()
    static var previews: some View {
        TelephoneView { x, y in print(x, y) }
    }
}
