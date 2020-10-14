import AVFoundation

// Helper functions
class Cookbook {
    static var sourceBuffer: AVAudioPCMBuffer {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        return try! AVAudioPCMBuffer(file: file)!
    }
}
