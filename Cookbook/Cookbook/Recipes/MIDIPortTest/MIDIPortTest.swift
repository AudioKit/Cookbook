import AudioKit
import AudioKitUI
import CoreMIDI
import Foundation
import SwiftUI

struct MIDIPortTestView: View {
    @StateObject var MIDIConductor: MIDIPortTestConductor = MIDIPortTestConductor()
    @State private var selectedPort1Uid: MIDIUniqueID?
    @State private var selectedPort2Uid: MIDIUniqueID?

    var body: some View {
        ScrollView {
            HStack(spacing: 60) {
                VStack {
                    HStack {
                        Text("Input Ports Available")
                            // .font(.title2)
                        Text("Destination Ports Available")
                            // .font(.title2)
                        Text("Virtual Input Ports Available")
                            // .font(.title2)
                        Text("Virtual Output Ports Available")
                            // .font(.title2)
                    }
                    HStack {
                        ForEach(0..<MIDIConductor.inputNames.count, id: \.self) { index in
                            VStack {
                                Text("\(MIDIConductor.inputNames[index])")
                                Text("\(MIDIConductor.inputUIDs[index])")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        ForEach(0..<MIDIConductor.destinationNames.count, id: \.self) { index in
                            VStack {
                                Text("\(MIDIConductor.destinationNames[index])")
                                Text("\(MIDIConductor.destinationUIDs[index])")
                                    .foregroundColor(.secondary)

                            }
                        }
                        Spacer()
                        ForEach(0..<MIDIConductor.virtualInputNames.count, id: \.self) { index in
                            VStack {
                                Text("\(MIDIConductor.virtualInputNames[index])")
                                Text("\(MIDIConductor.virtualInputUIDs[index])")
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        ForEach(0..<MIDIConductor.virtualOutputNames.count, id: \.self) { index in
                            VStack {
                                Text("\(MIDIConductor.virtualOutputNames[index])")
                                Text("\(MIDIConductor.virtualOutputUIDs[index])")
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
                        MIDIConductor.resetLog()
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
                        ForEach(0..<MIDIConductor.log.count, id: \.self) { index in
                            let event = MIDIConductor.log[index]
                            HStack {
                                Text("\(event.statusDescription)")
                                Text("\(event.channelDescription)")
                                Text("\(event.data1Description)")
                                Text("\(event.data2Description)")
                                Text("\(MIDIConductor.inputPortDescription(forUID: event.portUniqueID).UID)")
                                Text("\(MIDIConductor.inputPortDescription(forUID: event.portUniqueID).device)")
                                Text("\(MIDIConductor.inputPortDescription(forUID: event.portUniqueID).manufacturer)")
                            }
                            .foregroundColor(index == 0 ? .yellow : .primary)
                        }
                    }
                }
                Divider()
                HStack {
                    Picker(selection: $selectedPort1Uid, label:
                            Text("Destination Ports:")
                    ) {
                        Text("All")
                            .tag(nil as MIDIUniqueID?)
                        ForEach(0..<MIDIConductor.destinationUIDs.count, id: \.self) { index in

                            Text("\(MIDIConductor.destinationNames[index])")
                                .tag(MIDIConductor.destinationUIDs[index] as MIDIUniqueID?)
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
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send NoteOff 60") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.noteOff.rawValue,
                                                      channel: 0,
                                                      data1: 60,
                                                      data2: 90)
                        if selectedPort1Uid != nil {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 127") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 127)
                        if selectedPort1Uid != nil {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 0") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 0)

                        if selectedPort1Uid != nil {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort1Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                }
                HStack {
                    Picker(selection: $selectedPort2Uid, label:
                            Text("Virtual Output Ports:")
                    ) {
                        Text("All")
                            .tag(nil as MIDIUniqueID?)
                        ForEach(0..<MIDIConductor.virtualOutputUIDs.count, id: \.self) { index in
                            Text("\(MIDIConductor.virtualOutputNames[index])")
                                .tag(MIDIConductor.virtualOutputUIDs[index] as MIDIUniqueID?)
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
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send NoteOff 72") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.noteOff.rawValue,
                                                      channel: 0,
                                                      data1: 72,
                                                      data2: 90)
                        if selectedPort2Uid != nil {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 127") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 127)
                        if selectedPort2Uid != nil {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                    Button("Send Controller 82 - 0") {
                        let eventToSend = StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                                                      channel: 0,
                                                      data1: 82,
                                                      data2: 0)
                        if selectedPort2Uid != nil {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: [selectedPort2Uid!])
                        } else {
                            MIDIConductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
                        }
                    }
                }
                Divider()
                HStack {
                    Toggle(isOn: $MIDIConductor.outputIsOpen) {
                    }
                    Toggle(isOn: $MIDIConductor.inputPortIsSwapped) {
                    }
                    Toggle(isOn: $MIDIConductor.outputPortIsSwapped) {
                    }
                }
                HStack {
                    Text("use midi.openOutputs()")
                    Text("Swap UID for the virtual Input Port")
                    Text("Swap UID for the virtual Output Port")
                }
            }
        }
    }
}

struct MIDIPortTest_Previews: PreviewProvider {
    static var previews: some View {
        MIDIPortTestView()
    }
}
