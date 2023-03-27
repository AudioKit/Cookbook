import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

class ChannelDeviceRoutingConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var input: AudioEngine.InputNode?
    let inputDevices = Settings.session.availableInputs
    var inputDeviceList = [String]()

    init() {
        do {
            try Settings.setSession(category: .playAndRecord,
                                    with: [.defaultToSpeaker,
                                           .mixWithOthers,
                                           .allowBluetooth,
                                           .allowBluetoothA2DP])
            try Settings.session.setActive(true)
        } catch let err {
            Log(err.localizedDescription)
        }
        if let input = engine.input {
            self.input = input
            if let inputAudio = self.input {
                engine.output = Mixer(inputAudio)
            }
        } else {
            input = nil
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

struct ChannelDeviceRoutingView: View {
    @StateObject var conductor = ChannelDeviceRoutingConductor()

    @State var isPlaying = false
    @State var inputDevice: String = ""
    @State private var showingAlert = false
    @State private var headphonesIn = Settings.headPhonesPlugged
    var body: some View {
        VStack {
            Text("Input Devices")
                .font(.largeTitle)
            Picker("Input Device", selection: $inputDevice) {
                ForEach(conductor.inputDeviceList, id: \.self) { input in
                    Text(input).tag(input)
                }
            }
            .frame(width: 100, height: 200, alignment: .center)
            .onChange(of: inputDevice) { _ in
                let index = Int(inputDevice)
                conductor.switchInput(number: index)
            }
            Button(action: {
                if isPlaying {
                    self.isPlaying ? conductor.stop() : conductor.start()
                    self.isPlaying.toggle()
                } else {
                    if headphonesIn {
                        self.isPlaying ? conductor.stop() : conductor.start()
                        self.isPlaying.toggle()
                        showingAlert = false
                    } else {
                        showingAlert = true
                    }
                }

            }, label: {
                Image(systemName: isPlaying ? "mic.circle.fill" : "mic.circle")
                    .resizable()
                    .frame(minWidth: 25,
                           idealWidth: 50,
                           maxWidth: 100,
                           minHeight: 25,
                           idealHeight: 50,
                           maxHeight: 100,
                           alignment: .center)
                    .foregroundColor(.primary)
            })
            .keyboardShortcut(.space, modifiers: [])
        }
        .cookbookNavBarTitle("Channel/Device Routing")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Warning: Check your levels!"),
                  message: Text("Audio feedback may occur!"),
                  dismissButton: .destructive(Text("Proceed"), action: {
                      self.isPlaying ? conductor.stop() : conductor.start()
                      self.isPlaying.toggle()
                  }))
        }
    }
}
