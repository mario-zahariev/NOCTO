import SwiftUI

struct HeroParallaxCard: View, Equatable {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .noctoSurface(.hero, cornerRadius: Self.cornerRadius)
        .allowsHitTesting(false)
    }

    private static let cornerRadius: CGFloat = 20
    private static let height: CGFloat = 180
}
