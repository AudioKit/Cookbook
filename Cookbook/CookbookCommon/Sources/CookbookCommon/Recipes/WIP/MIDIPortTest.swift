import AudioKit
import AudioKitEX
import AudioKitUI
import CoreMIDI
import Foundation
import SwiftUI

struct MIDIPortTestView: View {
    @StateObject var conductor: MIDIPortTestConductor = .init()
    @State private var selectedPort1Uid: MIDIUniqueID?
    @State private var selectedPort2Uid: MIDIUniqueID?

    var body: some View {
        ScrollView {
            HStack(spacing: 60) {
                VStack {
                    HStack {
                        Text("Input Ports Available")
                        Text("Destination Ports Available")
                        Text("Virtual Input Ports Available")
                        Text("Virtual Output Ports Available")
                    }
                    HStack {
                        ForEach(0 ..< conductor.inputNames.count, id: \.self) { index in
                            VStack {
                                Text("\(conductor.inputNames[index])")
                                Text("\(conductor.inputUIDs[index])")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        ForEach(0 ..< conductor.destinationNames.count, id: \.self) { index in
                            VStack {
                                Text("\(conductor.destinationNames[index])")
                                Text("\(conductor.destinationUIDs[index])")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        ForEach(0 ..< conductor.virtualInputNames.count, id: \.self) { index in
                            VStack {
                                Text("\(conductor.virtualInputNames[index])")
                                Text("\(conductor.virtualInputUIDs[index])")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        ForEach(0 ..< conductor.virtualOutputNames.count, id: \.self) { index in
                            VStack {
                                Text("\(conductor.virtualOutputNames[index])")
                                Text("\(conductor.virtualOutputUIDs[index])")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
            VStack {
                HStack {
                    Button("Reset") {
                        conductor.resetLog()
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("StatusType")
                        Text("Channel")
                        Text("Data1")
                        Text("Data2")
                        Text("PortID")
                        Text("Device")
                        Text("Manufacturer")
                    }
                    .foregroundColor(.secondary)
                    ScrollView(.vertical) {
                        ForEach(0 ..< conductor.log.count, id: \.self) { index in
                            let event = conductor.log[index]
                            HStack {
                                Text("\(event.statusDescription)")
                                Text("\(event.channelDescription)")
                                Text("\(event.data1Description)")
                                Text("\(event.data2Description)")
                                Text("\(conductor.inputPortDescription(forUID: event.portUniqueID).UID)")
                                Text("\(conductor.inputPortDescription(forUID: event.portUniqueID).device)")
                                Text("\(conductor.inputPortDescription(forUID: event.portUniqueID).manufacturer)")
                            }
                            .foregroundColor(index == 0 ? .yellow : .primary)
                        }
                    }
                }
                Divider()
                HStack {
                    Picker(selection: $selectedPort1Uid, label:
                        Text("Destination Ports:")) {
                            Text("All")
                                .tag(nil as MIDIUniqueID?)
                            ForEach(0 ..< conductor.destinationNames.count, id: \.self) { index in

                                Text("\(conductor.destinationNames[index])")
                                    .tag(conductor.destinationUIDs[index] as MIDIUniqueID?)
                            }
                        }
                }
                HStack {
                    Button("Send NoteOn 60") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.noteOn.rawValue,
                                                      channel: 0,
                                                      data1: 60,
                                                      data2: 90)
                        if selectedPort1Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send NoteOff 60") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.noteOff.rawValue,
                                                      channel: 0,
                                                      data1: 60,
                                                      data2: 90)
                        if selectedPort1Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 127") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 127)
                        if selectedPort1Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 0") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 0)

                        if selectedPort1Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                }
                HStack {
                    Picker(selection: $selectedPort2Uid, label:
                        Text("Virtual Output Ports:")) {
                            Text("All")
                                .tag(nil as MIDIUniqueID?)
                            ForEach(0 ..< conductor.virtualOutputUIDs.count, id: \.self) { index in
                                Text("\(conductor.virtualOutputNames[index])")
                                    .tag(conductor.virtualOutputUIDs[index] as MIDIUniqueID?)
                            }
                        }
                }
                HStack {
                    Button("Send NoteOn 72") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.noteOn.rawValue,
                                                      channel: 0,
                                                      data1: 72,
                                                      data2: 90)
                        if selectedPort2Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send NoteOff 72") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.noteOff.rawValue,
                                                      channel: 0,
                                                      data1: 72,
                                                      data2: 90)
                        if selectedPort2Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 127") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 127)
                        if selectedPort2Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 0") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 0)
                        if selectedPort2Uid != nil {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                }
                Divider()
                HStack {
                    Toggle(isOn: $conductor.outputIsOpen) {}
                    Toggle(isOn: $conductor.inputPortIsSwapped) {}
                    Toggle(isOn: $conductor.outputPortIsSwapped) {}
                }
                HStack {
                    Text("use midi.openOutputs()")
                    Text("Swap UID for the virtual Input Port")
                    Text("Swap UID for the virtual Output Port")
                }
            }
        }
        .cookbookNavBarTitle("MIDI Port Test")
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }
}
