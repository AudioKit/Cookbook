import AudioKit
import AVFoundation
import SwiftUI

struct StereoDelayOperationData {
    var leftTime: AUValue = 0.2
    var leftFeedback: AUValue = 0.5
    var rightTime: AUValue = 0.01
    var rightFeedback: AUValue = 0.9
}

class StereoDelayOperationConductor: ObservableObject, ProcessesPlayerInput {
    let engine = AudioEngine()
    let player = AudioPlayer()
    let buffer: AVAudioPCMBuffer
    let effect: OperationEffect

    @Published var data = StereoDelayOperationData() {
        didSet {
            effect.parameter1 = data.leftTime
            effect.parameter2 = data.leftFeedback
            effect.parameter3 = data.rightTime
            effect.parameter4 = data.rightFeedback
        }
    }

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        effect = OperationEffect(player, channelCount: 2) { _, parameters in
            let leftDelay = Operation.leftInput.variableDelay(time: parameters[0], feedback: parameters[1])
            let rightDelay = Operation.rightInput.variableDelay(time: parameters[2], feedback: parameters[3])
            return [leftDelay, rightDelay]
        }
        effect.parameter1 = 0.2
        effect.parameter2 = 0.5
        effect.parameter3 = 0.01
        effect.parameter4 = 0.9

        engine.output = effect
    }

    func start() {
        do {
            try engine.start()
            // player stuff has to be done after start
            player.scheduleBuffer(buffer, at: nil, options: .loops)
        } catch let err {
            Log(err)
        }
    }
    func stop() {
        engine.stop()
    }
}

struct StereoDelayOperationView: View {
    @ObservedObject var conductor = StereoDelayOperationConductor()

    var body: some View {
        VStack(spacing: 20) {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Left Time",
                            parameter: self.$conductor.data.leftTime,
                            range: 0...0.3,
                            units: "Seconds")
            ParameterSlider(text: "Left Feedback",
                            parameter: self.$conductor.data.leftFeedback,
                            range: 0...1,
                            units: "%")
            ParameterSlider(text: "Right Time",
                            parameter: self.$conductor.data.rightTime,
                            range: 0...0.3,
                            units: "Seconds")
            ParameterSlider(text: "Right Feedback",
                            parameter: self.$conductor.data.rightFeedback,
                            range: 0...1,
                            units: "%")
        }
        .padding()
        .navigationBarTitle(Text("Stereo Delay Operation"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct StereoDelayOperation_Previews: PreviewProvider {
    static var previews: some View {
        StereoDelayOperationView()
    }
}
