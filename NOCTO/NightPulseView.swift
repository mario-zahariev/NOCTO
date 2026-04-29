import SwiftUI

struct NightPulseView: View {
    let snapshot: OperationalSnapshot

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                metricCard(title: "Активни места", value: "\(snapshot.venuesCount)")
                metricCard(title: "Здраве на decode", value: snapshot.decodeHealthLabel)
                metricCard(title: "Load latency", value: "\(snapshot.loadLatencyMs) ms")
                metricCard(title: "Трафик индекс", value: "\(snapshot.trafficIndex) / 100")
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
