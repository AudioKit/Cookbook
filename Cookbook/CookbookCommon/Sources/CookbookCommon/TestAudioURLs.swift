import Foundation

enum TestAudioURLs: String, CaseIterable {
    case beat = "beat.aiff",
         counting = "Counting.mp3",
         guitar = "Guitar.mp3"

    func url() -> URL? {
        return Bundle.main.resourceURL?.appendingPathComponent("Samples/\(self.rawValue)")
    }
}
