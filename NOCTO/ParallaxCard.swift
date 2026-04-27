import SwiftUI

struct ParallaxCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let minX = proxy.frame(in: .global).minX
            content
                .rotation3DEffect(.degrees(Double(minX / -20)), axis: (x: 0, y: 1, z: 0))
                .offset(x: minX > 0 ? -minX / 14 : 0)
        }
    }
}
