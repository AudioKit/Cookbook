import AudioKit
import AudioKitUI
import AVFoundation
import SwiftUI

// Helper functions
class Cookbook {
    static var sourceBuffer: AVAudioPCMBuffer {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        return try! AVAudioPCMBuffer(file: file)!
    }

    static func setupDryWetMixPlots(_ plots: NodeOutputPlot...) {
        let colors: [UIColor] = [.red, .blue, .purple]
        for (index, plot) in plots.enumerated() {
            plot.plotType = .rolling
            plot.color = colors[index]
            plot.shouldFill = true
            plot.shouldMirror = true
            plot.setRollingHistoryLength(128)
        }
    }
}
