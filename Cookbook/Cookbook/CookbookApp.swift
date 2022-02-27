// Copyright AudioKit. All Rights Reserved.

import SwiftUI
import AVFoundation
import AudioKit
import AudioKitUI

@main
struct CookbookApp: App {

    init() {
#if os(iOS)
        do {
            Settings.bufferLength = .short
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
            SplashView()
                .accentColor(ColorManager.accentColor)
        }
    }
}
