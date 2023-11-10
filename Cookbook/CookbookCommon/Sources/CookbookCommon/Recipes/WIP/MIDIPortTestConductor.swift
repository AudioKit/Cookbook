import AudioKit
import CoreMIDI
import Foundation
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
        return "\(channel + 1)"
    }

    var data1Description: String {
        switch statusType {
        case MIDIStatusType.noteOn.rawValue:
            return String(data1)
        case MIDIStatusType.noteOff.rawValue:
            return String(data1)
        case MIDIStatusType.controllerChange.rawValue:
            return data1.description + ": " + MIDIControl(rawValue: data1)!.description
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

    func start() {
        midi.openInput()
    }

    func stop() {
        midi.closeAllInputs()
    }

    init() {
        midi.createVirtualInputPorts(count: 1, uniqueIDs: [inputUIDDevelop])
        midi.createVirtualOutputPorts(count: 1, uniqueIDs: [outputUIDDevelop])
        midi.addListener(self)
    }

    func openOutputs() {
        for uid in midi.destinationUIDs {
            midi.openOutput(uid: uid)
        }
        for uid in midi.virtualOutputUIDs {
            midi.openOutput(uid: uid)
        }
    }

    struct PortDescription {
        var UID: String
        var manufacturer: String
        var device: String
        init(withUID: String, withManufacturer: String, withDevice: String) {
            UID = withUID
            manufacturer = withManufacturer
            device = withDevice
        }
    }

    private let logSize = 30
    func inputPortDescription(forUID: MIDIUniqueID?) -> PortDescription {
        print("inputPortDescription: \(String(describing: forUID))")
        var UIDString = forUID?.description ?? "-"
        var manufacturerString = "-"
        var deviceString = "-"
        if let UID = swapVirtualInputPort(withUID: forUID) {
            for index in 0 ..< inputInfos.count where inputInfos[index].midiUniqueID == UID {
                let info = inputInfos[index]

                UIDString = "\(info.midiUniqueID)"
                manufacturerString = info.manufacturer
                deviceString = info.displayName

                return PortDescription(withUID: UIDString,
                                       withManufacturer: manufacturerString,
                                       withDevice: deviceString)
            }
        }
        return PortDescription(withUID: UIDString,
                               withManufacturer: manufacturerString,
                               withDevice: deviceString)
    }

    func appendToLog(eventToAdd: StMIDIEvent) {
        log.insert(eventToAdd, at: 0)

        if log.count > logSize {
            log.remove(at: log.count - 1)
        }
    }

    func resetLog() {
        log.removeAll()
    }

    // MARK: - receive

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID?,
                            timeStamp _: MIDITimeStamp?)
    {
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
                             timeStamp _: MIDITimeStamp?)
    {
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
                                timeStamp _: MIDITimeStamp?)
    {
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
                                timeStamp _: MIDITimeStamp?)
    {
        DispatchQueue.main.async {
            self.appendToLog(eventToAdd: StMIDIEvent(statusType: MIDIStatusType.channelAftertouch.rawValue,
                                                     channel: channel,
                                                     data1: noteNumber,
                                                     data2: pressure,
                                                     portUniqueID: portID))
        }
    }

    func receivedMIDIAftertouch(_: MIDIByte,
                                channel _: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        //
    }

    func receivedMIDIPitchWheel(_: MIDIWord,
                                channel _: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        //
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID?,
                                   timeStamp _: MIDITimeStamp?)
    {
        DispatchQueue.main.async {
            self.appendToLog(eventToAdd: StMIDIEvent(statusType: MIDIStatusType.programChange.rawValue,
                                                     channel: channel,
                                                     data1: program,
                                                     portUniqueID: portID))
        }
    }

    func receivedMIDISystemCommand(_: [MIDIByte], portID _: MIDIUniqueID?, timeStamp _: MIDITimeStamp?) {
        //
    }

    func receivedMIDISetupChange() {
        //
    }

    func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {
        //
    }

    func receivedMIDINotification(notification _: MIDINotification) {
        //
    }

    func swapVirtualOutputPorts(withUID uid: [MIDIUniqueID]?) -> [MIDIUniqueID]? {
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

    func swapVirtualInputPort(withUID uid: MIDIUniqueID?) -> MIDIUniqueID? {
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
                                    channel: event.channel,
                                    endpointsUIDs: portIDs2)
        default:
            // Do Nothing
            ()
        }
    }
}
