import SwiftUI

struct VenueCard: View {
    let venue: Venue
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(venue.type.rawValue.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(NoctoTheme.textSecondary)
                Spacer()
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(NoctoTheme.accent)
                }
                .buttonStyle(.plain)
            }

            Text(venue.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(NoctoTheme.textPrimary)

            Text(venue.address)
                .font(.subheadline)
                .foregroundStyle(NoctoTheme.textSecondary)

            Text("Работно време: \(venue.workingHours)")
                .font(.footnote)
                .foregroundStyle(NoctoTheme.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NoctoTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(NoctoTheme.cardBorder, lineWidth: 1)
        )
        .microFeedback()
    }
}
