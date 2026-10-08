//
//  LetterSealAnimationView.swift
//  Postbox


import SwiftUI
internal import Combine

@MainActor
final class LetterSealViewModel: ObservableObject {

    // The written page tucking down into the envelope.
    @Published private(set) var paperOffset: CGFloat = 0
    @Published private(set) var paperScale: CGFloat = 1
    @Published private(set) var paperOpacity: Double = 1

    // Open stack (EnvelopeBackView + EnvelopeFrontPocketView), crossfades out.
    @Published private(set) var openStackOpacity: Double = 1
    @Published private(set) var closedOpacity: Double = 0
    @Published private(set) var closedScale: CGFloat = 0.94

    // Wax seal stamp, dropped in once the envelope has closed.
    @Published private(set) var sealOpacity: Double = 0
    @Published private(set) var sealOffset: CGFloat = -320
    @Published private(set) var sealScaleX: CGFloat = 1
    @Published private(set) var sealScaleY: CGFloat = 1
    @Published private(set) var isComplete = false

    private(set) var isSealed = false

    func seal() {
        guard !isSealed else { return }
        isSealed = true

        // 1. Page tucks down into the envelope and fades.
        withAnimation(.easeInOut(duration: 0.25)) {
            paperOffset = 60
            paperScale = 0.55
        }
        withAnimation(.easeIn(duration: 0.2).delay(0.05)) {
            paperOpacity = 0
        }

        // 2. Open stack (back panel + front pocket) fades out — mirrors
        // close()'s openStackOpacity beat.
        withAnimation(.easeInOut(duration: 0.2).delay(0.2)) {
            openStackOpacity = 0
        }

        // 3. Closed envelope fades/scales in — identical timing to close().
        withAnimation(.easeOut(duration: 0.25).delay(0.3)) {
            closedOpacity = 1
            closedScale = 1
        }

        // 4. Wax seal drops in...
        withAnimation(.easeIn(duration: 0.22).delay(0.65)) {
            sealOpacity = 1
            sealOffset = -160 // roughly the closed envelope's vertical center
        }
        // ...and settles with a quick squash/rebound on impact.
        withAnimation(.easeOut(duration: 0.15).delay(0.87)) {
            sealScaleX = 1.15
            sealScaleY = 0.85
        }
        withAnimation(.easeOut(duration: 0.15).delay(1.02)) {
            sealScaleX = 1
            sealScaleY = 1
        }

        // 5. Reveal "Sealed" + the Back to Home button.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.isComplete = true
            }
        }
    }
}

struct LetterSealAnimationView<Content: View>: View {
    @StateObject private var viewModel = LetterSealViewModel()
    let sealImage: Image?
    let onFinish: () -> Void
    let content: Content

    private let envelopeHeight: CGFloat = 520

    init(
        sealImage: Image?,
        onFinish: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.sealImage = sealImage
        self.onFinish = onFinish
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 36) {
                ZStack(alignment: .bottom) {
                    EnvelopeBackView()
                        .frame(width: 680, height: envelopeHeight)
                        .offset(y: -28)
                        .opacity(viewModel.openStackOpacity)

                    content
                        .scaleEffect(3.4)
                        .scaleEffect(viewModel.paperScale)
                        .offset(y: viewModel.paperOffset)
                        .opacity(viewModel.paperOpacity)

                    EnvelopeFrontPocketView()
                        .frame(width: 680, height: envelopeHeight * 0.8)
                        .opacity(viewModel.openStackOpacity)

                    EnvelopeClosedView()
                        .frame(width: 680, height: envelopeHeight)
                        .scaleEffect(viewModel.closedScale)
                        .opacity(viewModel.closedOpacity)

                    if let sealImage {
                        sealImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170, height: 170)
                            .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                            .opacity(viewModel.sealOpacity)
                            .offset(y: viewModel.sealOffset)
                            .scaleEffect(x: viewModel.sealScaleX, y: viewModel.sealScaleY)
                    }
                }
                .frame(width: 680, height: envelopeHeight)
                .padding(.top, 80)
    

                if viewModel.isComplete {
                    VStack(spacing: 18) {
                        Text("Sealed!")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(30)

                        Button(action: onFinish) {
                            Text("Back to Home")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(.systemBackground))
                                .frame(minWidth: 260, minHeight: 64)
                                .background(
                                    Capsule()
                                        .fill(Color.primary)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.seal()
        }
    }
}
