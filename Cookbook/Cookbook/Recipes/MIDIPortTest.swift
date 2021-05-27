import AudioKit
import AudioKitUI
import CoreMIDI
import Foundation
import SwiftUI

extension MIDIByte {

    var controllerDescription: String {

        switch self {
        case 0:     return "Bank MSB"
        case 1:     return "Modulation"
        case 2:     return "Breath"
        case 3:     return "Ctrl 3"
        case 4:     return "Foot Control"
        case 5:     return "Portamento Time"
        case 6:     return "Data MSB"
        case 7:     return "Volume"
        case 8:     return "Balance"
        case 9:     return "Ctrl 9"
        case 10:    return "Pan"
        case 11:    return "Expression"
        case 12:    return "Effect #1 MSB"
        case 13:    return "Effect #2 MSB"
        case 14:    return "Ctrl 14"
        case 15:    return "Ctrl 15"
        case 16:    return "General #1"
        case 17:    return "General #2"
        case 18:    return "General #3"
        case 19:    return "General #4"
        case 20:    return "Ctrl 20"
        case 21:    return "Ctrl 21"
        case 22:    return "Ctrl 22"
        case 23:    return "Ctrl 23"
        case 24:    return "Ctrl 24"
        case 25:    return "Ctrl 25"
        case 26:    return "Ctrl 26"
        case 27:    return "Ctrl 27"
        case 28:    return "Ctrl 28"
        case 29:    return "Ctrl 29"
        case 30:    return "Ctrl 30"
        case 31:    return "Ctrl 31"
        case 32:    return "Bank LSB"
        case 33:    return "(#01 LSB)"
        case 34:    return "(#02 LSB)"
        case 35:    return "(#03 LSB)"
        case 36:    return "(#04 LSB)"
        case 37:    return "(#05 LSB)"
        case 38:    return "Data LSB"
        case 39:    return "(#07 LSB)"
        case 40:    return "(#08 LSB)"
        case 41:    return "(#09 LSB)"
        case 42:    return "(#10 LSB)"
        case 43:    return "(#11 LSB)"
        case 44:    return "Effect #1 LSB"
        case 45:    return "Effect #2 LSB"
        case 46:    return "(#14 LSB)"
        case 47:    return "(#15 LSB)"
        case 48:    return "(#16 LSB)"
        case 49:    return "(#17 LSB)"
        case 50:    return "(#18 LSB)"
        case 51:    return "(#19 LSB)"
        case 52:    return "(#20 LSB)"
        case 53:    return "(#21 LSB)"
        case 54:    return "(#22 LSB)"
        case 55:    return "(#23 LSB)"
        case 56:    return "(#24 LSB)"
        case 57:    return "(#25 LSB)"
        case 58:    return "(#26 LSB)"
        case 59:    return "(#27 LSB)"
        case 60:    return "(#28 LSB)"
        case 61:    return "(#29 LSB)"
        case 62:    return "(#30 LSB)"
        case 63:    return "(#31 LSB)"
        case 64:    return "Sustain"
        case 65:    return "Portamento"
        case 66:    return "Sostenuto"
        case 67:    return "Soft Pedal "
        case 68:    return "Legato"
        case 69:    return "Hold 2"
        case 70:    return "Sound Variation"
        case 71:    return "Timbre"
        case 72:    return "Release Time"
        case 73:    return "Attack Time"
        case 74:    return "Brightness"
        case 75:    return "Decay Time"
        case 76:    return "Vibrato Rate"
        case 77:    return "Vibrato Depth"
        case 78:    return "Vibrato Delay"
        case 79:    return "Ctrl 79"
        case 80:    return "Decay"
        case 81:    return "HPF Frequency"
        case 82:    return "General #7"
        case 83:    return "General #8"
        case 84:    return "Portamento Control"
        case 85:    return "Ctrl 85"
        case 86:    return "Ctrl 86"
        case 87:    return "Ctrl 87"
        case 88:    return "High Res Velocity Prefix"
        case 89:    return "Ctrl 89"
        case 90:    return "Ctrl 90"
        case 91:    return "Reverb"
        case 92:    return "Tremolo Depth"
        case 93:    return "Chorus Send Level"
        case 94:    return "Celeste (Detune) Depth"
        case 95:    return "Phaser Depth"
        case 96:    return "Data Increment"
        case 97:    return "Data Entry Decrement"
        case 98:    return "Non-Reg. LSB"
        case 99:    return "Non-Reg. MSB"
        case 100:   return "Reg.Par. LSB"
        case 101:   return "Reg.Par. MSB"
        case 102:   return "Ctrl 102"
        case 103:   return "Ctrl 103"
        case 104:   return "Ctrl 104"
        case 105:   return "Ctrl 105"
        case 106:   return "Ctrl 106"
        case 107:   return "Ctrl 107"
        case 108:   return "Ctrl 108"
        case 109:   return "Ctrl 109"
        case 110:   return "Ctrl 110"
        case 111:   return "Ctrl 111"
        case 112:   return "Ctrl 112"
        case 113:   return "Ctrl 113"
        case 114:   return "Ctrl 114"
        case 115:   return "Ctrl 115"
        case 116:   return "Ctrl 116"
        case 117:   return "Ctrl 117"
        case 118:   return "Ctrl 118"
        case 119:   return "Ctrl 119"
        case 120:   return "All Sounds Off"
        case 121:   return "Reset All Controllers"
        case 122:   return "Local Control"
        case 123:   return "All Notes Off"
        case 124:   return "Omni Mode Off"
        case 125:   return "Omni Mode On"
        case 126:   return "Mono Mode On"
        case 127:   return "Poly Mode On"

        default:
            return "-"
        }
    }

    /// YAMAHA 60 = C3
    var noteDescriptionYamaha: String {

        let array = ["C-2",
                     "C#-2",
                     "D-2",
                     "D#-2",
                     "E-2",
                     "F-2",
                     "F#-2",
                     "G-2",
                     "G#-2",
                     "A-2",
                     "A#-2",
                     "B-2",
                     "C-1",
                     "C#-1",
                     "D-1",
                     "D#-1",
                     "E-1",
                     "F-1",
                     "F#-1",
                     "G-1",
                     "G#-1",
                     "A-1",
                     "A#-1",
                     "B-1",
                     "C0",
                     "C#0",
                     "D0",
                     "D#0",
                     "E0",
                     "F0",
                     "F#0",
                     "G0",
                     "G#0",
                     "A0",
                     "A#0",
                     "B0",
                     "C1",
                     "C#1",
                     "D1",
                     "D#1",
                     "E1",
                     "F1",
                     "F#1",
                     "G1",
                     "G#1",
                     "A1",
                     "A#1",
                     "B1",
                     "C2",
                     "C#2",
                     "D2",
                     "D#2",
                     "E2",
                     "F2",
                     "F#2",
                     "G2",
                     "G#2",
                     "A2",
                     "A#2",
                     "B2",
                     "C3",
                     "C#3",
                     "D3",
                     "D#3",
                     "E3",
                     "F3",
                     "F#3",
                     "G3",
                     "G#3",
                     "A3",
                     "A#3",
                     "B3",
                     "C4",
                     "C#4",
                     "D4",
                     "D#4",
                     "E4",
                     "F4",
                     "F#4",
                     "G4",
                     "G#4",
                     "A4",
                     "A#4",
                     "B4",
                     "C5",
                     "C#5",
                     "D5",
                     "D#5",
                     "E5",
                     "F5",
                     "F#5",
                     "G5",
                     "G#5",
                     "A5",
                     "A#5",
                     "B5",
                     "C6",
                     "C#6",
                     "D6",
                     "D#6",
                     "E6",
                     "F6",
                     "F#6",
                     "G6",
                     "G#6",
                     "A6",
                     "A#6",
                     "B6",
                     "C7",
                     "C#7",
                     "D7",
                     "D#7",
                     "E7",
                     "F7",
                     "F#7",
                     "G7",
                     "G#7",
                     "A7",
                     "A#7",
                     "B7",
                     "C8",
                     "C#8",
                     "D8",
                     "D#8",
                     "E8",
                     "F8",
                     "F#8",
                     "G8"
        ]

        if  self < 128 {
            return array[Int(self)]
        }

        return "-"
    }

    /// ROLAND 60 = C4
    var noteDescriptionRoland: String {

        let array = [ "C-1",
                      "C#-1",
                      "D-1",
                      "D#-1",
                      "E-1",
                      "F-1",
                      "F#-1",
                      "G-1",
                      "G#-1",
                      "A-1",
                      "A#-1",
                      "B-1",
                      "C0",
                      "C#0",
                      "D0",
                      "D#0",
                      "E0",
                      "F0",
                      "F#0",
                      "G0",
                      "G#0",
                      "A0",
                      "A#0",
                      "B0",
                      "C1",
                      "C#1",
                      "D1",
                      "D#1",
                      "E1",
                      "F1",
                      "F#1",
                      "G1",
                      "G#1",
                      "A1",
                      "A#1",
                      "B1",
                      "C2",
                      "C#2",
                      "D2",
                      "D#2",
                      "E2",
                      "F2",
                      "F#2",
                      "G2",
                      "G#2",
                      "A2",
                      "A#2",
                      "B2",
                      "C3",
                      "C#3",
                      "D3",
                      "D#3",
                      "E3",
                      "F3",
                      "F#3",
                      "G3",
                      "G#3",
                      "A3",
                      "A#3",
                      "B3",
                      "C4",
                      "C#4",
                      "D4",
                      "D#4",
                      "E4",
                      "F4",
                      "F#4",
                      "G4",
                      "G#4",
                      "A4",
                      "A#4",
                      "B4",
                      "C5",
                      "C#5",
                      "D5",
                      "D#5",
                      "E5",
                      "F5",
                      "F#5",
                      "G5",
                      "G#5",
                      "A5",
                      "A#5",
                      "B5",
                      "C6",
                      "C#6",
                      "D6",
                      "D#6",
                      "E6",
                      "F6",
                      "F#6",
                      "G6",
                      "G#6",
                      "A6",
                      "A#6",
                      "B6",
                      "C7",
                      "C#7",
                      "D7",
                      "D#7",
                      "E7",
                      "F7",
                      "F#7",
                      "G7",
                      "G#7",
                      "A7",
                      "A#7",
                      "B7",
                      "C8",
                      "C#8",
                      "D8",
                      "D#8",
                      "E8",
                      "F8",
                      "F#8",
                      "G8",
                      "G#8",
                      "A8",
                      "A#8",
                      "B8",
                      "C9",
                      "C#9",
                      "D9",
                      "D#9",
                      "E9",
                      "F9",
                      "F#9",
                      "G9",
                      "G#9"
        ]

        if  self < 128 {
            return array[Int(self)]
        }

        return "-"
    }
}

struct StMIDIEvent: Decodable, Encodable {

    var statusType: Int // AudioKit MIDIStatusType enum
    var channel: MIDIChannel
    var data1: MIDIByte
    var data2: MIDIByte?
    var portUniqueID: MIDIUniqueID?

    var statusDescription: String {
        if let stat = MIDIStatusType(rawValue: statusType) {
            return stat.description
        }
        return "-"
    }

    var channelDescription: String {
        return "\(channel+1)"
    }

    var data1Description: String {

        switch statusType {
        case MIDIStatusType.noteOn.rawValue:
            return data1.noteDescriptionYamaha
        case MIDIStatusType.noteOff.rawValue:
            return data1.noteDescriptionYamaha
        case MIDIStatusType.controllerChange.rawValue:
            return data1.description + ": " + data1.controllerDescription
        case MIDIStatusType.programChange.rawValue:
            return data1.description
        default:
            return "-"
        }

    }

    var data2Description: String {

        if data2 != nil {
            switch statusType {
            case MIDIStatusType.noteOn.rawValue:
                return data2!.description
            case MIDIStatusType.noteOff.rawValue:
                return data2!.description
            case MIDIStatusType.controllerChange.rawValue:
                return data2!.description
            default:
                return "-"
            }
        } else {
            return "-"
        }
    }
}

class MIDIPortTestConductor: ObservableObject, MIDIListener {
    let inputUIDDevelop: Int32 = 1_200_000
    let outputUIDDevelop: Int32 = 1_500_000
    let inputUIDMain: Int32 = 2_200_000
    let outputUIDMain: Int32 = 2_500_000
    let midi = MIDI()
    @Published var log = [StMIDIEvent]()
    @Published var outputIsOpen: Bool = false {
        didSet {
            print("outputIsOpen: \(outputIsOpen)")
            if outputIsOpen {
                openOutputs()
            } else {
                midi.closeOutput()
            }
        }
    }
    @Published var outputPortIsSwapped: Bool = false
    @Published var inputPortIsSwapped: Bool = false
    init() {
        /// Develop
        midi.createVirtualInputPorts(count: 1, uniqueIDs: [inputUIDDevelop])
        midi.createVirtualOutputPorts(count: 1, uniqueIDs: [outputUIDDevelop])
        /// Main
//        midi.createVirtualInputPorts(numberOfPort: 1, [inputUIDMain], names: ["MIDI Test Input Port_Main"])
//        midi.createVirtualOutputPorts(numberOfPort: 1, [outputUIDMain], names: ["MIDI Test Output Port_Main"])
        midi.openInput()
        midi.addListener(self)
    }
    func openOutputs () {
        for uid in midi.destinationUIDs {
            midi.openOutput(uid: uid)
        }
        for uid in midi.virtualOutputUIDs {
            midi.openOutput(uid: uid)
        }
    }
    var inputNames: [String] {
        midi.inputNames
    }
    var inputUIDs: [MIDIUniqueID] {
        midi.inputUIDs
    }
    var inputInfos: [EndpointInfo] {
        midi.inputInfos
    }
    var virtualInputNames: [String] {
        midi.virtualInputNames
    }
    var virtualInputUIDs: [MIDIUniqueID] {
        midi.virtualInputUIDs
    }
    var virtualInputInfos: [EndpointInfo] {
        midi.virtualInputInfos
    }
    var destinationNames: [String] {
        midi.destinationNames
    }
    var destinationUIDs: [MIDIUniqueID] {
        midi.destinationUIDs
    }
    var destinationInfos: [EndpointInfo] {
        midi.destinationInfos
    }
    var virtualOutputNames: [String] {
        midi.virtualOutputNames
    }
    var virtualOutputUIDs: [MIDIUniqueID] {
        midi.virtualOutputUIDs
    }
    var virtualOutputInfos: [EndpointInfo] {
        midi.virtualOutputInfos
    }
    private let logSize = 30
    func inputPortDescription(forUID: MIDIUniqueID?) -> (UID: String, manufacturer: String, device: String) {
        print("inputPortDescription: \(String(describing: forUID))")
        var UIDString = forUID?.description ?? "-"
        var manufacturerString = "-"
        var deviceString = "-"
        if let UID = swapVirtualInputPort(withUID: forUID) {

            for index in 0..<inputInfos.count {

                if inputInfos[index].midiUniqueID == UID {

                    let info = inputInfos[index]

                    UIDString = "\(info.midiUniqueID)"
                    manufacturerString = info.manufacturer
                    deviceString = info.displayName

                    return (UID: UIDString, manufacturer: manufacturerString, device: deviceString)
                }
            }
        }
        return (UID: UIDString, manufacturer: manufacturerString, device: deviceString)
    }
    func appendToLog (eventToAdd: StMIDIEvent) {

        log.insert(eventToAdd, at: 0)

        if log.count > logSize {
            log.remove(at: log.count-1)
        }
    }
    func resetLog () {
        log.removeAll()
    }
    // MARK: - receive
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID?,
                            timeStamp: MIDITimeStamp?) {

        DispatchQueue.main.async {
            print("noteOn Received")
            self.appendToLog(eventToAdd: StMIDIEvent(statusType: MIDIStatusType.noteOn.rawValue,
                               channel: channel,
                               data1: noteNumber,
                               data2: velocity,
                               portUniqueID: portID))
        }
    }
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID?,
                             timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            self.appendToLog(eventToAdd: StMIDIEvent(statusType: MIDIStatusType.noteOff.rawValue,
                               channel: channel,
                               data1: noteNumber,
                               data2: velocity,
                               portUniqueID: portID))
        }
    }
    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            self.appendToLog(eventToAdd: StMIDIEvent(statusType: MIDIStatusType.controllerChange.rawValue,
                               channel: channel,
                               data1: controller,
                               data2: value,
                               portUniqueID: portID))
        }
    }
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            self.appendToLog(eventToAdd: StMIDIEvent(statusType: MIDIStatusType.channelAftertouch.rawValue,
                               channel: channel,
                               data1: noteNumber,
                               data2: pressure,
                               portUniqueID: portID))
        }
    }
    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        //
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID?,
                                timeStamp: MIDITimeStamp?) {
        //
    }
    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID?,
                                   timeStamp: MIDITimeStamp?) {
        DispatchQueue.main.async {
            self.appendToLog(eventToAdd: StMIDIEvent(statusType: MIDIStatusType.programChange.rawValue,
                               channel: channel,
                               data1: program,
                               portUniqueID: portID))
        }
    }
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        //
    }

    func receivedMIDISetupChange() {
        //
    }

    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        //
    }

    func receivedMIDINotification(notification: MIDINotification) {
        //
    }
    func swapVirtualOutputPorts (withUID uid: [MIDIUniqueID]?) -> [MIDIUniqueID]? {
        if uid != nil {
            if outputPortIsSwapped {
                switch uid {
//                case [inputUIDMain]: return [outputUIDMain]
                case [outputUIDMain]: return [inputUIDMain]
//                case [inputUIDDevelop]: return [outputUIDDevelop]
                case [outputUIDDevelop]: return [inputUIDDevelop]

                default:
                    return uid
                }
            }
        }
        return uid
    }

    func swapVirtualInputPort (withUID uid: MIDIUniqueID?) -> MIDIUniqueID? {
        if uid != nil {
            if inputPortIsSwapped {
                switch uid {
                case outputUIDMain: return inputUIDMain
                case outputUIDDevelop: return inputUIDDevelop
                default:
                    return uid
                }
            }
        }
        return uid
    }
    // MARK: - Send
    func sendEvent(eventToSend event: StMIDIEvent, portIDs: [MIDIUniqueID]?) {
        print("sendEvent")
        let portIDs2: [MIDIUniqueID]? = swapVirtualOutputPorts(withUID: portIDs)
        if portIDs2 != nil {
            print("sendEvent, port: \(portIDs2![0].description)")
        }
        switch event.statusType {
        case MIDIStatusType.controllerChange.rawValue:
            //                print("sendEvent controllerChange, port: \(portIDs2![0].description)")
            midi.sendControllerMessage(event.data1,
                                       value: event.data2 ?? 0,
                                       channel: event.channel,
                                       endpointsUIDs: portIDs2)
        case MIDIStatusType.programChange.rawValue:
            //                print("sendEvent programChange, port: \(portIDs2![0].description)")
            midi.sendEvent(MIDIEvent(programChange: event.data1,
                                     channel: event.channel),
                                     endpointsUIDs: portIDs2)
        case MIDIStatusType.noteOn.rawValue:
            //                print("sendEvent noteOn, port: \(portIDs2![0].description)")
            midi.sendNoteOnMessage(noteNumber: event.data1,
                                   velocity: event.data2 ?? 0,
                                   channel: event.channel,
                                   endpointsUIDs: portIDs2)
        case MIDIStatusType.noteOff.rawValue:
            //                print("sendEvent noteOn, port: \(portIDs2![0].description)")
            midi.sendNoteOffMessage(noteNumber: event.data1,
                                   velocity: event.data2 ?? 0,
                                   channel: event.channel,
                                   endpointsUIDs: portIDs2)
        default:
            // Do Nothing
            ()
        }
    }
}

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
