import SwiftUI

struct HeroParallaxCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        ParallaxCard {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [NoctoTheme.card, NoctoTheme.accent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
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
            .frame(height: 180)
        }
        .frame(height: 180)
    }
}
