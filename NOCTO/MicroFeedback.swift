import SwiftUI

struct MicroFeedback: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: isPressed)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    isPressed = pressing
                },
                perform: {}
            )
    }
}

extension View {
    func microFeedback() -> some View {
        modifier(MicroFeedback())
    }
}
