import SwiftUI
import NOCTOCore
#if DEBUG
import QuartzCore
import os
#endif

struct HomeView: View {
    let venues: [Venue]
    @ObservedObject var favorites: FavoritesManager
    @GestureState private var isScrollInteracting = false
    #if DEBUG
    @State private var scrollHitchMonitor = DebugScrollHitchMonitor(tag: "HomeView.Scroll")
    #endif

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    HeroParallaxCard(title: "NOCTO", subtitle: "Интелигентен гид за нощна София")
                        .equatable()
                        .padding(.horizontal, 16)

                    ForEach(venues) { venue in
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
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 10)
            }
            .scrollInteractionActive(isScrollInteracting)
            .simultaneousGesture(
                DragGesture(minimumDistance: 2)
                    .updating($isScrollInteracting) { _, state, _ in
                        state = true
                    }
            )
            .transaction { transaction in
                if isScrollInteracting {
                    transaction.disablesAnimations = true
                }
            }
            .onChange(of: isScrollInteracting, initial: false) { _, isInteracting in
                handleScrollInteractionChange(isInteracting)
            }
            .onDisappear {
                stopScrollPerformanceTracking()
            }
            .background(NoctoTheme.background.ignoresSafeArea())
            .navigationTitle("Начало")
        }
    }
}

private extension HomeView {
    func handleScrollInteractionChange(_ isInteracting: Bool) {
        #if DEBUG
        if isInteracting {
            scrollHitchMonitor.beginTracking()
        } else {
            scrollHitchMonitor.endTracking()
        }
        #endif
    }

    func stopScrollPerformanceTracking() {
        #if DEBUG
        scrollHitchMonitor.endTracking()
        #endif
    }
}

#if DEBUG
@MainActor
private final class DebugScrollHitchMonitor: NSObject {
    private let tag: String
    private let logger = Logger(subsystem: "com.mario.NOCTO", category: "Performance")
    private var displayLink: CADisplayLink?
    private var previousTimestamp: CFTimeInterval = 0
    private var lastLoggedTimestamp: CFTimeInterval = 0

    init(tag: String) {
        self.tag = tag
    }

    func beginTracking() {
        guard displayLink == nil else { return }
        previousTimestamp = 0
        lastLoggedTimestamp = 0

        let displayLink = CADisplayLink(target: self, selector: #selector(handleFrame))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
        logger.debug("[\(self.tag, privacy: .public)] started")
    }

    func endTracking() {
        guard let displayLink else { return }
        displayLink.invalidate()
        self.displayLink = nil
        previousTimestamp = 0
        logger.debug("[\(self.tag, privacy: .public)] stopped")
    }

    @objc private func handleFrame(_ displayLink: CADisplayLink) {
        guard previousTimestamp > 0 else {
            previousTimestamp = displayLink.timestamp
            return
        }

        let frameDelta = displayLink.timestamp - previousTimestamp
        previousTimestamp = displayLink.timestamp

        let hitchThreshold: CFTimeInterval = 0.024
        guard frameDelta >= hitchThreshold else { return }

        let throttlingWindow: CFTimeInterval = 0.5
        guard displayLink.timestamp - lastLoggedTimestamp >= throttlingWindow else { return }
        lastLoggedTimestamp = displayLink.timestamp

        let milliseconds = Int((frameDelta * 1000).rounded())
        logger.debug("[\(self.tag, privacy: .public)] hitch \(milliseconds, privacy: .public)ms")
    }
}
#endif
