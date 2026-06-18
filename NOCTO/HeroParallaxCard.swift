import SwiftUI

struct HeroParallaxCard: View, Equatable {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [NoctoTheme.card, NoctoTheme.accent.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .stroke(NoctoTheme.cardBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(NoctoTheme.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(NoctoTheme.textSecondary)
            }
            .padding(16)
        }
        .frame(height: Self.height)
        .allowsHitTesting(false)
    }

    private static let cornerRadius: CGFloat = 20
    private static let height: CGFloat = 180
}
