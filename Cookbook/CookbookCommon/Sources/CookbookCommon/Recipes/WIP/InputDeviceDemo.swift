import AudioKit
import AudioKitEX
import AudioKitUI
import SwiftUI

class InputDeviceDemoConductor: ObservableObject, HasAudioEngine {
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
                ForEach(conductor.inputDeviceList, id: \.self) { input in
                    Text(input).tag(input)
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
                self.isPlaying ? conductor.stop() : conductor.start()
                self.isPlaying.toggle()

            }, label: {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
            })
            .keyboardShortcut(.space, modifiers: [])
        }
        .cookbookNavBarTitle("Input Device Demo")
    }
}
