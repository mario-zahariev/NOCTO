import SwiftUI

struct MicroFeedback: ViewModifier {
    @GestureState private var isPressed = false
    @Environment(\.isScrollInteractionActive) private var isScrollInteractionActive

    func body(content: Content) -> some View {
        let shouldApplyPressFeedback = isPressed && !isScrollInteractionActive

        content
            .scaleEffect(shouldApplyPressFeedback ? 0.985 : 1)
            .animation(.easeOut(duration: 0.1), value: shouldApplyPressFeedback)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        guard !isScrollInteractionActive else { return }
                        state = true
                    }
            )
    }
}

extension View {
    func microFeedback() -> some View {
        modifier(MicroFeedback())
    }

    func scrollInteractionActive(_ isActive: Bool) -> some View {
        environment(\.isScrollInteractionActive, isActive)
    }
}

private struct ScrollInteractionActiveKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var isScrollInteractionActive: Bool {
        get { self[ScrollInteractionActiveKey.self] }
        set { self[ScrollInteractionActiveKey.self] = newValue }
    }
}
