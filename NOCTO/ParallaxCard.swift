import SwiftUI

private struct ParallaxMinXPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ParallaxCard<Content: View>: View {
    let content: Content
    @State private var minX: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .rotation3DEffect(.degrees(Double(minX / -20)), axis: (x: 0, y: 1, z: 0))
            .offset(x: minX > 0 ? -minX / 14 : 0)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ParallaxMinXPreferenceKey.self,
                        value: proxy.frame(in: .global).minX
                    )
                }
            )
            .onPreferenceChange(ParallaxMinXPreferenceKey.self) { value in
                minX = value
            }
    }
}
