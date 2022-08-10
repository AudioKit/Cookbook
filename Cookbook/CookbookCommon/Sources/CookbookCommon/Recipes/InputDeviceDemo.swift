import AudioKit
import AudioKitUI
import SwiftUI

class InputDeviceDemoConductor: ObservableObject {
    let engine = AudioEngine()
    var mic: AudioEngine.InputNode?
    let inputDevices = Settings.session.availableInputs
    var inputDeviceList = [String]()

    init() {
        if let input = engine.input {
            mic = input
            if let inputAudio = mic {
                engine.output = Mixer(inputAudio)
            }
        } else {
            mic = nil
            engine.output = Mixer()
        }
        if let existingInputs = inputDevices {
            for device in existingInputs {
                inputDeviceList.append(device.portName)
            }
        }
    }

    func switchInput(number: Int?) {
        stop()
        if let inputs = Settings.session.availableInputs {
            let newInput = inputs[number ?? 0]
            do {
                try Settings.session.setPreferredInput(newInput)
                try Settings.session.setActive(true)
            } catch let err {
                Log(err)
            }
        }
    }

    func start() {
        do { try engine.start() } catch let err { Log(err) }
    }

    func stop() {
        engine.stop()
    }
}

struct InputDeviceDemoView: View {
    @StateObject var conductor = InputDeviceDemoConductor()

    @State var isPlaying = false
    @State var inputDevice: String = ""
    var body: some View {
        VStack {
            Text("Please plug in headphones to avoid a feedback loop.")
            Text("Then, select a device to start!")
            Picker("Input Device", selection: $inputDevice) {
                ForEach(0 ..< conductor.inputDeviceList.count) {
                    Text(self.conductor.inputDeviceList[$0]).tag("\($0)")
                }
            }
            Text("For multiple input devices,")
            Text("create an Aggregate Device")
            Text("with the devices you want in it.")
                .onChange(of: inputDevice) { _ in
                    let index = Int(inputDevice)
                    conductor.switchInput(number: index)
                }
                .padding(.bottom)
            Button(action: {
                self.isPlaying ? self.conductor.stop() : self.conductor.start()
                self.isPlaying.toggle()

            }, label: {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
            })
            .keyboardShortcut(.space, modifiers: [])
        }
    }
}
