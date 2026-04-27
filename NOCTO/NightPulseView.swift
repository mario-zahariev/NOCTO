import SwiftUI

struct NightPulseView: View {
    let venuesCount: Int

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                metricCard(title: "Активни места", value: "\(venuesCount)")
                metricCard(title: "Пиков интервал", value: "23:30 - 01:30")
                metricCard(title: "Трафик индекс", value: "74 / 100")
                Spacer()
            }
            .padding(20)
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Night Pulse")
        }
    }

    private func metricCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(NoctoTheme.textSecondary)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(NoctoTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(NoctoTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(NoctoTheme.cardBorder, lineWidth: 1)
        )
    }
}
