import SwiftUI

struct CookbookNavBarTitle: ViewModifier {
    var text: String
    func body(content: Content) -> some View {
        content
        #if !os(macOS)
        .navigationBarTitle(Text(text))
        #endif
    }
}

extension View {
    func cookbookNavBarTitle(_ text: String) -> some View {
        modifier(CookbookNavBarTitle(text: text))
    }
}
