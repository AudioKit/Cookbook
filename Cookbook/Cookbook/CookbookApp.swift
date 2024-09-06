// Copyright AudioKit. All Rights Reserved.

import AudioKit
import AVFoundation
import CookbookCommon
import SwiftUI

@main
struct CookbookApp: App {
    init() {
        #if os(iOS)
            do {
                Settings.bufferLength = .short
                
                let deviceSampleRate = AVAudioSession.sharedInstance().sampleRate
                if deviceSampleRate > Settings.sampleRate {
                    // Update sampleRate to 48_000. Default is 44_100.
                    Settings.sampleRate = deviceSampleRate
                }
                
                
                try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                                options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let err {
                print(err)
            }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
