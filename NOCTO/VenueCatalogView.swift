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
                NoctoHTMLHomeBackground()
                    .ignoresSafeArea()

                content
            }
            .toolbar(.hidden, for: .navigationBar)
            .ignoresSafeArea()
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
            NoctoVenueFeedView(
                venues: viewModel.venues,
                favorites: favorites,
                statusMessage: viewModel.errorMessage,
                onRefresh: onRefresh
            )
        }
    }
}

struct NoctoVenueFeedView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager
    var statusMessage: String?
    let onRefresh: () async -> Void

    var body: some View {
        GeometryReader { proxy in
            let scale = NoctoHTML.scale(for: proxy.size)

            ZStack(alignment: .top) {
                NoctoHTMLHomeBackground()
                    .ignoresSafeArea()

                NoctoHTMLStatusBar(scale: scale)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 11 * scale) {
                        NoctoTonightHeader(scale: scale)

                        NoctoCityPulseMeter(scale: scale)

                        if let statusMessage {
                            VenueCatalogStatusBanner(message: statusMessage, scale: scale)
                        }

                        VStack(alignment: .leading, spacing: 6 * scale) {
                            Text("Близо до теб")
                                .font(.system(size: 7 * scale, weight: .bold))
                                .tracking(3 * scale)
                                .textCase(.uppercase)
                                .foregroundStyle(NoctoTheme.textTertiary)
                                .padding(.bottom, 2 * scale)

                            ForEach(Array(htmlCardVenues.enumerated()), id: \.offset) { _, venue in
                                NavigationLink {
                                    VenueDetailView(venue: venue)
                                } label: {
                                    VenueCard(
                                        venue: venue,
                                        isFavorite: favorites.isFavorite(venue.id),
                                        badge: VenueSignalResolver.badge(for: venue),
                                        onToggleFavorite: {
                                            favorites.toggle(venue.id)
                                            Haptics.tap()
                                        },
                                        scale: scale
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.top, (50 + 14) * scale)
                    .padding(.horizontal, 17 * scale)
                    .padding(.bottom, 112 * scale)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .refreshable {
                    await onRefresh()
                }
            }
            .ignoresSafeArea()
        }
    }

    private var htmlCardVenues: [Venue] {
        let hot = venues.first { $0.noctoState == .hot }
        let event = venues.first { $0.noctoState == .event }
        let afterhours = venues.first { $0.noctoState == .afterhours }
        let fallback = venues.first

        return [hot ?? fallback, event ?? fallback, afterhours ?? fallback].compactMap { $0 }
    }
}

private struct NoctoHTMLHomeBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                NoctoTheme.background,
                Color(hex: "#10070C"),
                Color(hex: "#21060F")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct NoctoTonightHeader: View {
    let scale: CGFloat

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1 * scale) {
                Text("Tonight in Sofia")
                    .font(.system(size: 8 * scale, weight: .bold))
                    .tracking(3 * scale)
                    .textCase(.uppercase)
                    .foregroundStyle(NoctoTheme.textTertiary)

                Text("Добра вечер, Mario ✦")
                    .font(.system(size: 17 * scale, weight: .heavy))
                    .foregroundStyle(NoctoTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8 * scale)

            VStack(alignment: .trailing, spacing: 3 * scale) {
                Text("23:14")
                    .font(.system(size: 11 * scale, weight: .bold))
                    .foregroundStyle(NoctoTheme.textPrimary)

                HStack(spacing: 5 * scale) {
                    Circle()
                        .fill(NoctoTheme.accent)
                        .frame(width: 6 * scale, height: 6 * scale)

                    Text("Live")
                        .font(.system(size: 7 * scale, weight: .bold))
                        .tracking(2 * scale)
                        .textCase(.uppercase)
                        .foregroundStyle(NoctoTheme.accent)
                }
            }
        }
        .padding(.horizontal, 12 * scale)
        .padding(.vertical, 8 * scale)
        .background(
            RoundedRectangle(cornerRadius: 11 * scale)
                .fill(NoctoTheme.accent.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 11 * scale)
                .stroke(NoctoTheme.accent.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct NoctoCityPulseMeter: View {
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 7 * scale) {
            HStack {
                Text("Пулс на София")
                    .font(.system(size: 8 * scale, weight: .bold))
                    .tracking(3 * scale)
                    .textCase(.uppercase)
                    .foregroundStyle(NoctoTheme.textTertiary)

                Spacer()

                Text("Петък · Висок")
                    .font(.system(size: 8 * scale, weight: .regular))
                    .foregroundStyle(NoctoTheme.textSecondary)
            }

            NoctoHTMLVUBars(scale: scale, small: false, state: .hot)
                .frame(height: 34 * scale)

            HStack {
                pulseStat("47", "Активни", tint: NoctoTheme.accent)
                pulseStat("2.3k", "Онлайн", tint: NoctoTheme.textPrimary)
                pulseStat("Висок", "Пулс", tint: NoctoTheme.event)
            }
        }
        .padding(.horizontal, 14 * scale)
        .padding(.top, 11 * scale)
        .padding(.bottom, 9 * scale)
        .background(
            RoundedRectangle(cornerRadius: 13 * scale)
                .fill(NoctoTheme.accent.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13 * scale)
                .stroke(NoctoTheme.accent.opacity(0.09), lineWidth: 1)
        )
    }

    private func pulseStat(_ value: String, _ label: String, tint: Color) -> some View {
        VStack(spacing: 1 * scale) {
            Text(value)
                .font(.system(size: 12 * scale, weight: .black))
                .tracking(-0.5 * scale)
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(label)
                .font(.system(size: 6 * scale, weight: .bold))
                .tracking(2 * scale)
                .textCase(.uppercase)
                .foregroundStyle(NoctoTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct VenueCatalogLoadingView: View {
    var body: some View {
        GeometryReader { proxy in
            let scale = NoctoHTML.scale(for: proxy.size)

            ZStack {
                NoctoHTMLHomeBackground()
                    .ignoresSafeArea()

                NoctoHTMLStatusBar(scale: scale)

                VStack(spacing: 12 * scale) {
                    NoctoHTMLVUBars(scale: scale, small: false, state: .hot)
                        .frame(width: 96 * scale)

                    Text("Зареждане на NOCTO каталог...")
                        .font(.system(size: 12 * scale, weight: .bold))
                        .foregroundStyle(NoctoTheme.textPrimary)
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct VenueCatalogFailureView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let scale = NoctoHTML.scale(for: proxy.size)

            ZStack {
                NoctoHTMLHomeBackground()
                    .ignoresSafeArea()

                NoctoHTMLStatusBar(scale: scale)

                VStack(spacing: 12 * scale) {
                    Text("Проблем при зареждането")
                        .font(.system(size: 16 * scale, weight: .heavy))
                        .foregroundStyle(NoctoTheme.textPrimary)

                    Text(message)
                        .font(.system(size: 10 * scale, weight: .semibold))
                        .foregroundStyle(NoctoTheme.textSecondary)
                        .multilineTextAlignment(.center)

                    Button(action: onRetry) {
                        Text("Опитай отново")
                            .font(.system(size: 9 * scale, weight: .black))
                            .tracking(2 * scale)
                            .textCase(.uppercase)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(NoctoTheme.accent)
                }
                .padding(22 * scale)
            }
            .ignoresSafeArea()
        }
    }
}

private struct VenueCatalogEmptyView: View {
    var body: some View {
        GeometryReader { proxy in
            let scale = NoctoHTML.scale(for: proxy.size)

            ZStack {
                NoctoHTMLHomeBackground()
                    .ignoresSafeArea()

                NoctoHTMLStatusBar(scale: scale)

                Text("Няма налични заведения")
                    .font(.system(size: 16 * scale, weight: .heavy))
                    .foregroundStyle(NoctoTheme.textPrimary)
            }
            .ignoresSafeArea()
        }
    }
}

private struct VenueCatalogStatusBanner: View {
    let message: String
    let scale: CGFloat

    var body: some View {
        Text(message)
            .font(.system(size: 8 * scale, weight: .semibold))
            .foregroundStyle(NoctoTheme.gold)
            .lineLimit(2)
            .padding(8 * scale)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .fill(NoctoTheme.gold.opacity(0.055))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8 * scale)
                    .stroke(NoctoTheme.gold.opacity(0.18), lineWidth: 1)
            )
    }
}
