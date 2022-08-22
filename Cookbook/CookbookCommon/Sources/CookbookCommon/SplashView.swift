import SwiftUI

public struct SplashView: View {
    @State private var isContentReady = false

    public init() {}

    public var body: some View {
        ZStack {
            if self.isContentReady {
                ContentView()
            } else {
                VStack(spacing: 0) {
                    Image("audiokit-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3)
                    Image("audiokit-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 217,
                               height: 120)
                }
            }
        }
        .onAppear {
            DispatchQueue.main
                .asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.isContentReady.toggle()
                    }
                }
        }
    }
}
