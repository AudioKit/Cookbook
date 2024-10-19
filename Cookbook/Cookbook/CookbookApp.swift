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

                // Settings.sampleRate default is 44_100
                if #available(iOS 18.0, *) {
                    if !ProcessInfo.processInfo.isMacCatalystApp && !ProcessInfo.processInfo.isiOSAppOnMac {
                        // Set samplerRate for iOS 18 and newer
                        Settings.sampleRate = 48_000
                    }
                }
                if #available(macOS 15.0, *) {
                    // Set samplerRate for macOS 15 and newer
                    Settings.sampleRate = 48_000
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
