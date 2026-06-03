import SwiftUI
import NOCTOCore

struct VenueCatalogView: View {
    @ObservedObject private var viewModel: VenueCatalogViewModel
    @ObservedObject private var favorites: FavoritesManager

    private let onInitialLoad: () async -> Void
    private let onRefresh: () async -> Void

    init(
        viewModel: VenueCatalogViewModel,
        favorites: FavoritesManager,
        onInitialLoad: @escaping () async -> Void,
        onRefresh: @escaping () async -> Void
    ) {
        self.viewModel = viewModel
        self.favorites = favorites
        self.onInitialLoad = onInitialLoad
        self.onRefresh = onRefresh
    }

    var body: some View {
        NavigationStack {
            ZStack {
                catalogBackdrop

                content
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Каталог")
            .task {
                guard viewModel.loadState == .idle else { return }
                await onInitialLoad()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.venues.isEmpty {
            VenueCatalogLoadingView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.venues.isEmpty {
            VenueCatalogFailureView(message: errorMessage) {
                Task { await onInitialLoad() }
            }
        } else if viewModel.venues.isEmpty {
            VenueCatalogEmptyView()
        } else {
            catalogList
        }
    }

    private var catalogList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                VenueCatalogHeader(venues: viewModel.venues)
                    .padding(.horizontal, 16)

                if let errorMessage = viewModel.errorMessage {
                    VenueCatalogStatusBanner(message: errorMessage)
                        .padding(.horizontal, 16)
                }

                ForEach(viewModel.venues) { venue in
                    VenueRowView(
                        venue: venue,
                        isFavorite: favorites.isFavorite(venue.id),
                        onToggleFavorite: {
                            favorites.toggle(venue.id)
                            Haptics.tap()
                        }
                    )
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 10)
        }
        .refreshable {
            await onRefresh()
        }
    }

    private var catalogBackdrop: some View {
        ZStack {
            RadialGradient(
                colors: [
                    NoctoTheme.accent.opacity(0.12),
                    NoctoTheme.accent.opacity(0.03),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 16,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    NoctoTheme.ultraviolet.opacity(0.14),
                    NoctoTheme.ultraviolet.opacity(0.04),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 520
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct VenueCatalogHeader: View {
    let venues: [Venue]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("НОЩЕН КАТАЛОГ")
                        .font(.caption2.weight(.black))
                        .tracking(1.7)
                        .foregroundStyle(NoctoTheme.accent)

                    Text("NOCTO")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(NoctoTheme.textPrimary)

                    Text("Проверени локални сигнали за тази вечер")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(NoctoTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                NoctoSignalWave()
                    .frame(width: 54, height: 54)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    signalPill(value: "\(venues.count)", label: "заведения")
                    signalPill(value: primaryTypeLabel, label: "водещ тип")
                    signalPill(value: lateCoverageLabel, label: "късно покритие")
                }

                VStack(alignment: .leading, spacing: 8) {
                    signalPill(value: "\(venues.count)", label: "заведения")
                    signalPill(value: primaryTypeLabel, label: "водещ тип")
                    signalPill(value: lateCoverageLabel, label: "късно покритие")
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .noctoSurface(.hero, cornerRadius: 24)
    }

    private func signalPill(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(NoctoTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(NoctoTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .noctoSurface(.embeddedPocket, cornerRadius: 14)
    }

    private var primaryTypeLabel: String {
        let grouped = Dictionary(grouping: venues, by: \.type)
        guard let primaryType = grouped.max(by: { lhs, rhs in
            if lhs.value.count == rhs.value.count {
                return lhs.key.catalogLabel > rhs.key.catalogLabel
            }
            return lhs.value.count < rhs.value.count
        })?.key else {
            return "няма"
        }

        return primaryType.catalogLabel.lowercased()
    }

    private var lateCoverageLabel: String {
        let closingMinutes = venues.compactMap { venue -> Int? in
            guard
                let opening = Venue.hourMinuteTuple(from: venue.workingHours, at: 0),
                let closing = Venue.hourMinuteTuple(from: venue.workingHours, at: 1)
            else { return nil }

            let openingValue = opening.h * 60 + opening.m
            let closingValue = closing.h * 60 + closing.m
            return closingValue <= openingValue ? closingValue + 24 * 60 : closingValue
        }

        guard let latest = closingMinutes.max() else { return "няма" }
        let normalized = latest % (24 * 60)
        return "до \(String(format: "%02d:%02d", normalized / 60, normalized % 60))"
    }
}

private struct VenueRowView: View {
    let venue: Venue
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        NavigationLink {
            VenueDetailView(venue: venue)
        } label: {
            VenueCard(
                venue: venue,
                isFavorite: isFavorite,
                badge: VenueSignalResolver.badge(for: venue),
                onToggleFavorite: onToggleFavorite
            )
        }
        .buttonStyle(.plain)
    }
}

private struct VenueCatalogLoadingView: View {
    var body: some View {
        VStack(spacing: 18) {
            ProgressView()
                .scaleEffect(1.25)
                .tint(NoctoTheme.accent)

            Text("Зареждане на NOCTO каталог...")
                .font(.headline.weight(.bold))
                .foregroundStyle(NoctoTheme.textPrimary)
        }
        .padding(24)
        .noctoSurface(.raised, cornerRadius: 18)
    }
}

private struct VenueCatalogFailureView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "Проблем при зареждането",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
            .foregroundStyle(NoctoTheme.textPrimary)

            Button(action: onRetry) {
                Label("Опитай отново", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .tint(NoctoTheme.accent)
        }
        .padding(22)
    }
}

private struct VenueCatalogEmptyView: View {
    var body: some View {
        ContentUnavailableView(
            "Няма налични заведения",
            systemImage: "mappin.slash",
            description: Text("Каталогът на NOCTO в момента е празен.")
        )
        .foregroundStyle(NoctoTheme.textPrimary)
        .padding(22)
    }
}

private struct VenueCatalogStatusBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(NoctoTheme.accent)

            Text(message)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(NoctoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .noctoSurface(.embeddedPocket, cornerRadius: 14, tint: NoctoTheme.accent)
    }
}

private extension VenueCore.VenueType {
    var catalogLabel: String {
        switch self {
        case .club: return "Клуб"
        case .bar: return "Бар"
        case .lounge: return "Лаундж"
        case .event: return "Събитие"
        case .other: return "Друго"
        }
    }
}
