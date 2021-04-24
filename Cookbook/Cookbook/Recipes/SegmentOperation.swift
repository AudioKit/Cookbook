import AudioKit
import AudioKitUI
import SwiftUI

class SegmentOperationConductor: ObservableObject {
    let engine = AudioEngine()

    @Published var isRunning = false {
        didSet {
            isRunning ? generator.start() : generator.stop()
        }
    }

    let generator = OperationGenerator { parameters in
        let updateRate = parameters[0]

        // Vary the starting frequency and duration randomly
        let start = Operation.randomNumberPulse() * 2_000 + 300
        let duration = Operation.randomNumberPulse()
        let frequency = Operation.lineSegment(trigger: Operation.metronome(frequency: updateRate),
                                              start: start,
                                              end: 0,
                                              duration: duration)

        // Decrease the amplitude exponentially
        let amplitude = Operation.exponentialSegment(trigger: Operation.metronome(frequency: updateRate),
                                                     start: 0.3,
                                                     end: 0.01,
                                                     duration: 1.0 / updateRate)
        return Operation.sineWave(frequency: frequency, amplitude: amplitude)
    }
    init() {
        let delay = Delay(generator)
        generator.parameter1 = 2.0

        //: Add some effects for good fun
        delay.time = 0.125
        delay.feedback = 0.8
        let reverb = Reverb(delay)
        reverb.loadFactoryPreset(.largeHall)

        engine.output = reverb
    }

    func start() {
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }
    func stop() {
        engine.stop()
    }
}

struct SegmentOperationView: View {
    @StateObject var conductor = SegmentOperationConductor()

    var body: some View {
        VStack(spacing: 20) {
            Text("Creating segments that vary parameters in operations linearly or exponentially over a certain duration")
            Text(conductor.isRunning ? "Stop" : "Start").onTapGesture {
                conductor.isRunning.toggle()
            }
        }
        .padding()
        .navigationBarTitle(Text("Segment Operation"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}
