import SwiftUI

/// Top-level card: layers the closed envelope over the opened stack and
/// lets the view model's animated values crossfade between them.
///
/// The frame here is taller than the envelope art itself on purpose —
/// the paper rises `paperOffset` points above the envelope's own bounds
/// when open, so the card needs headroom reserved above the envelope for
/// that peek to actually be visible instead of getting clipped.
struct EnvelopeOpenCardView: View {
    let closedOpacity: Double
    let closedScale: CGFloat
    let openStackOpacity: Double
    let paperOffset: CGFloat
    let paperOpacity: Double
    let previewText: String
    let showPeekText: Bool

    private let envelopeHeight: CGFloat = 220
    private let peekHeadroom: CGFloat = 100 // must be >= the largest paperOffset magnitude

    var body: some View {
        ZStack(alignment: .bottom) {
            OpenEnvelopeStackView(
                paperOffset: paperOffset,
                paperOpacity: paperOpacity,
                previewText: previewText,
                showPeekText: showPeekText
            )
            .frame(height: envelopeHeight)
            .opacity(openStackOpacity)

            EnvelopeClosedView()
                .frame(height: envelopeHeight)
                .scaleEffect(closedScale)
                .opacity(closedOpacity)
        }
        .frame(width: 300, height: envelopeHeight + peekHeadroom, alignment: .bottom)
        // No .clipped() here on purpose — clipping this card is what
        // truncates the peeking paper. If a parent container clips
        // (ScrollView/List/NavigationLink), that's the thing to fix instead.
    }
}
