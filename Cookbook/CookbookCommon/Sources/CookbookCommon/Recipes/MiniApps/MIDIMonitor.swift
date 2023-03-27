import AudioKit
import AudioKitEX
import AudioKitUI
import CoreMIDI
import Foundation
import SwiftUI

// struct representing last data received of each type

struct MIDIMonitorData {
    var noteOn = 0
    var velocity = 0
    var noteOff = 0
    var channel = 0
    var afterTouch = 0
    var afterTouchNoteNumber = 0
    var programChange = 0
    var pitchWheelValue = 0
    var controllerNumber = 0
    var controllerValue = 0
}

enum MIDIEventType {
    case none
    case noteOn
    case noteOff
    case continuousControl
    case programChange
}

class MIDIMonitorConductor: ObservableObject, MIDIListener {
    let midi = MIDI()
    @Published var data = MIDIMonitorData()
    @Published var isShowingMIDIReceived: Bool = false
    @Published var isToggleOn: Bool = false
    @Published var oldControllerValue: Int = 0
    @Published var midiEventType: MIDIEventType = .none

    init() {}

    func start() {
        midi.openInput(name: "Bluetooth")
        midi.openInput()
        midi.addListener(self)
    }

    func stop() {
        midi.closeAllInputs()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID _: MIDIUniqueID?,
                            timeStamp _: MIDITimeStamp?)
    {
        print("noteNumber \(noteNumber) \(noteNumber)")
        print("velocity \(velocity) \(velocity)")
        DispatchQueue.main.async {
            self.midiEventType = .noteOn
            self.isShowingMIDIReceived = true
            self.data.noteOn = Int(noteNumber)
            self.data.velocity = Int(velocity)
            self.data.channel = Int(channel)
            if self.data.velocity == 0 {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isShowingMIDIReceived = false
                }
            }
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID _: MIDIUniqueID?,
                             timeStamp _: MIDITimeStamp?)
    {
        print("noteNumber \(noteNumber) \(noteNumber)")
        print("velocity \(velocity) \(velocity)")
        DispatchQueue.main.async {
            self.midiEventType = .noteOff
            self.isShowingMIDIReceived = false
            self.data.noteOff = Int(noteNumber)
            self.data.velocity = Int(velocity)
            self.data.channel = Int(channel)
        }
    }

    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("controller \(controller) \(value)")
        DispatchQueue.main.async {
            self.midiEventType = .continuousControl
            self.isShowingMIDIReceived = true
            self.data.controllerNumber = Int(controller)
            self.data.controllerValue = Int(value)
            self.oldControllerValue = Int(value)
            self.data.channel = Int(channel)
            if self.oldControllerValue == Int(value) {
                // Fade out the MIDI received indicator.
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.4)) {
                        self.isShowingMIDIReceived = false
                    }
                }
            }
            // Show the solid color indicator when the CC value is toggled from 0 to 127
            // Otherwise toggle it off when the CC value is toggled from 127 to 0
            // Useful for stomp box and on/off UI toggled states
            if value == 127 {
                DispatchQueue.main.async {
                    self.isToggleOn = true
                }
            } else {
                // Fade out the Toggle On indicator.
                DispatchQueue.main.async {
                    self.isToggleOn = false
                }
            }
        }
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("received after touch")
        DispatchQueue.main.async {
            self.data.afterTouch = Int(pressure)
            self.data.channel = Int(channel)
        }
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("recv'd after touch \(noteNumber)")
        DispatchQueue.main.async {
            self.data.afterTouchNoteNumber = Int(noteNumber)
            self.data.afterTouch = Int(pressure)
            self.data.channel = Int(channel)
        }
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        print("midi wheel \(pitchWheelValue)")
        DispatchQueue.main.async {
            self.data.pitchWheelValue = Int(pitchWheelValue)
            self.data.channel = Int(channel)
        }
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID _: MIDIUniqueID?,
                                   timeStamp _: MIDITimeStamp?)
    {
        print("Program change \(program)")
        DispatchQueue.main.async {
            self.midiEventType = .programChange
            self.isShowingMIDIReceived = true
            self.data.programChange = Int(program)
            self.data.channel = Int(channel)
            // Fade out the MIDI received indicator, since program changes don't have a MIDI release/note off.
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isShowingMIDIReceived = false
                }
            }
        }
    }

    func receivedMIDISystemCommand(_: [MIDIByte],
                                   portID _: MIDIUniqueID?,
                                   timeStamp _: MIDITimeStamp?)
    {
//        print("sysex")
    }

    func receivedMIDISetupChange() {
        // Do nothing
    }

    func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    func receivedMIDINotification(notification _: MIDINotification) {
        // Do nothing
    }
}

struct MIDIMonitorView: View {
    @StateObject private var conductor = MIDIMonitorConductor()

    var body: some View {
        VStack {
            midiReceivedIndicator
            List {
                Section("Note On") {
                    HStack {
                        Text("Note Number")
                        Spacer()
                        Text("\(conductor.data.noteOn)")
                    }
                    HStack {
                        Text("Note Velocity")
                        Spacer()
                        Text("\(conductor.data.velocity)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .noteOn ? .blue : .primary)
                Section("Note Off") {
                    HStack {
                        Text("Note Number")
                        Spacer()
                        Text("\(conductor.data.noteOff)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .noteOff ? .blue : .primary)
                Section("Continuous Controller") {
                    HStack {
                        Text("Controller Number")
                        Spacer()
                        Text("\(conductor.data.controllerNumber)")
                    }
                    HStack {
                        Text("Continuous Value")
                        Spacer()
                        Text("\(conductor.data.controllerValue)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .continuousControl ? .blue : .primary)
                Section("Program Change") {
                    HStack {
                        Text("Program Number")
                        Spacer()
                        Text("\(conductor.data.programChange)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .programChange ? .blue : .primary)
                Section {
                    HStack {
                        Text("Selected MIDI Channel")
                        Spacer()
                        Text("\(conductor.data.channel)")
                    }
                }
            }
            .cookbookNavBarTitle("MIDI Monitor")
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
        }
    }

    var midiReceivedIndicator: some View {
        HStack(spacing: 15) {
            Text("MIDI In")
                .fontWeight(.medium)
            Circle()
                .strokeBorder(.blue.opacity(0.5), lineWidth: 1)
                .background(Circle().fill(conductor.isShowingMIDIReceived ? .blue : .blue.opacity(0.2)))
                .frame(maxWidth: 20, maxHeight: 20)
            Spacer()
            Text("Toggle On")
                .fontWeight(.medium)
            Circle()
                .strokeBorder(.red.opacity(0.5), lineWidth: 1)
                .background(Circle().fill(conductor.isToggleOn ? .red : .red.opacity(0.2)))
                .frame(maxWidth: 20, maxHeight: 20)
                .shadow(color: conductor.isToggleOn ? .red : .clear, radius: 5)
        }
        .padding([.top, .horizontal], 20)
        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
    }
}
