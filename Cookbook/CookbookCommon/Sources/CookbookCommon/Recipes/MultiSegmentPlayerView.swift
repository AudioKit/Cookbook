import AudioKit
import AudioKitUI
import SwiftUI

class MultiSegmentPlayerConductor: ObservableObject {
    let engine = AudioEngine()
    let player = MultiSegmentAudioPlayer()
    
    var timer: Timer!
    var timePrevious: TimeInterval = TimeInterval(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
    @Published var endTime: TimeInterval
    @Published var _timeStamp: TimeInterval = 0
    var timeStamp: TimeInterval {
        get{
            return _timeStamp
        }
        set{
            _timeStamp = newValue.clamped(to: 0...endTime)

            if newValue > endTime {
                isPlaying = false
                _timeStamp = 0
            }
        }
    }
    
    var segments: [MockSegment]
    var rmsFramesPerSecond: Double = 15
    var pixelsPerRMS: Double = 1

    @Published var isPlaying: Bool = false {
        didSet {
            if !isPlaying {
                player.stop()
            } else {
                timePrevious = TimeInterval(DispatchTime.now().uptimeNanoseconds) * 1_000_000_000
                player.playSegments(audioSegments: segments, referenceTimeStamp: timeStamp)
            }
        }
    }

    

    init() {
        let segment1 = try! MockSegment(audioFileURL: TestAudioURLs.beat.url()!,
                                        playbackStartTime: 0.0,
                                        rmsFramesPerSecond: rmsFramesPerSecond)

        let segment2 = try! MockSegment(audioFileURL: TestAudioURLs.highTom.url()!,
                                        playbackStartTime: segment1.playbackEndTime + 1.0,
                                        rmsFramesPerSecond: rmsFramesPerSecond)

        let segment3 = try! MockSegment(audioFileURL: TestAudioURLs.midTom.url()!,
                                        playbackStartTime: segment2.playbackEndTime,
                                        rmsFramesPerSecond: rmsFramesPerSecond)

        let segment4 = try! MockSegment(audioFileURL: TestAudioURLs.midTom.url()!,
                                        playbackStartTime: segment3.playbackEndTime + 0.5,
                                        rmsFramesPerSecond: rmsFramesPerSecond)

        let segment5 = try! MockSegment(audioFileURL: TestAudioURLs.lowTom.url()!,
                                        playbackStartTime: segment4.playbackEndTime,
                                        rmsFramesPerSecond: rmsFramesPerSecond)

        let segment6 = try! MockSegment(audioFileURL: TestAudioURLs.lowTom.url()!,
                                        playbackStartTime: segment5.playbackEndTime + 0.5,
                                        rmsFramesPerSecond: rmsFramesPerSecond)

        let segment7 = try! MockSegment(audioFileURL: TestAudioURLs.highTom.url()!,
                                        playbackStartTime: segment6.playbackEndTime,
                                        rmsFramesPerSecond: rmsFramesPerSecond)

        segments = [segment1, segment2, segment3, segment4, segment5, segment6, segment7]

        endTime = segment7.playbackEndTime

        setAudioSessionCategoriesWithOptions()
        routeAudioToOutput()
        startAudioEngine()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(checkTime), userInfo: nil, repeats: true)
    }

    @objc func checkTime() {
        if isPlaying {
            let timeNow = TimeInterval(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
            timeStamp += (timeNow - timePrevious)
            timePrevious = timeNow
        }
    }

    func setAudioSessionCategoriesWithOptions() {
        do {
            try AudioKit.Settings.session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
            try AudioKit.Settings.session.setActive(true)
        } catch {
            assert(false, error.localizedDescription)
        }
    }

    func routeAudioToOutput() {
        engine.output = player
    }

    func startAudioEngine() {
        do { try engine.start() }
        catch { assert(false, error.localizedDescription) }
    }
}

struct MultiSegmentPlayerView: View {
    @ObservedObject var conductor = MultiSegmentPlayerConductor()

    var currentTimeText: String {
        let currentTime = String(format: "%.1f", conductor.timeStamp)
        let endTime = String(format: "%.1f", conductor.endTime)
        return currentTime + " of " + endTime
    }

    var currentPlayPosition: CGFloat {
        let pixelsPerSecond = conductor.pixelsPerRMS * conductor.rmsFramesPerSecond
        return conductor.timeStamp * pixelsPerSecond - playheadWidth
    }

    let playheadWidth: CGFloat = 2

    var body: some View {
        VStack{
            ZStack(alignment: .leading) {
                TrackView(segments: conductor.segments,
                          rmsFramesPerSecond: conductor.rmsFramesPerSecond,
                          pixelsPerRMS: conductor.pixelsPerRMS)

                Rectangle()
                    .fill(.red)
                    .frame(width: playheadWidth)
                    .offset(x: currentPlayPosition)
            }
            .frame(height: 200)
            .padding()

            PlayPauseView(isPlaying: $conductor.isPlaying).frame(height: 30)

            Text(currentTimeText)
                .padding(.top)

            Spacer()
        }
        .navigationBarTitle(Text("Multi Segment Player"))
    }

    struct PlayPauseView: View {
        @Binding var isPlaying: Bool

        var body: some View {
            Image(systemName: !isPlaying ? "play" : "pause")
                .resizable()
                .scaledToFit()
                .frame(width: 24)
                .contentShape(Rectangle())
                .onTapGesture { isPlaying.toggle() }
        }
    }
}

struct MultiSegmentPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MultiSegmentPlayerView()
    }
}

// Duplicated from AudioKit
extension Comparable {
    // ie: 5.clamped(to: 7...10)
    // ie: 5.0.clamped(to: 7.0...10.0)
    // ie: "a".clamped(to: "b"..."h")
    /// **OTCore:**
    /// Returns the value clamped to the passed range.
    dynamic fileprivate func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
