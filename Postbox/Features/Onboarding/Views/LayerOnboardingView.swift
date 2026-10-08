//
//  LayerOnboardingView.swift
//  Postbox
//

import SwiftUI

struct LayerOnboardingView: View {
    @Binding var hasLayerOnboarding: Bool
    @Binding var showLayerOnboarding: Bool
    @Binding var toolButtonFrames: [String: ToolButtonFramePreference]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Dark backdrop — tap anywhere to close
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { closeOnboarding() }

                if let pref = toolButtonFrames["layer"] {
                    // Highlighted layer icon in the toolbar
                    highlightedButton(at: pref.frame)

                    // onboardingLayer image shown near the button
                    onboardingImage(at: pref.frame, in: proxy.size)

                    // Title, description, and close hint
                    VStack(spacing: 0) {
                        Spacer()
                        titleBlock(in: proxy.size)
                        Spacer()
                        closeHint
                            .padding(.bottom, 120)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(6)
                } else {
                    fallbackContent
                }
            }
        }
        .zIndex(4)
    }

    // MARK: - Highlighted button (sits on top of the dark overlay)
    private func highlightedButton(at frame: CGRect) -> some View {
        let size = max(frame.width, frame.height)
        return Image("button_layer")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
            .position(x: frame.midX, y: frame.midY)
            .allowsHitTesting(false)
            .zIndex(5)
    }

    // MARK: - onboardingLayer image anchored near the button
    private func onboardingImage(at frame: CGRect, in size: CGSize) -> some View {
        let isLandscape = size.width > size.height
        // Much smaller — just large enough to be readable but not overlapping the title
        let imageWidth: CGFloat = isLandscape
            ? min(150, size.width * 0.14)
            : min(180, size.width * 0.22)

        // Appear directly below the layer button with a small gap.
        // Use frame.midX as anchor so it aligns with the button,
        // but clamp so it never clips out of bounds on the right side.
        let xPos = min(frame.midX, size.width - imageWidth * 0.5 - 16)
        // Top of image = bottom of button + small gap; centre the image from there.
        let yPos = frame.maxY + 10 + imageWidth * 0.5

        return Image("onboardingLayer")
            .resizable()
            .scaledToFit()
            .frame(width: imageWidth)
            .position(x: xPos, y: yPos)
            .allowsHitTesting(false)
            .zIndex(5)
    }

    // MARK: - Title + description block (centred, lower half)
    private func titleBlock(in size: CGSize) -> some View {
        let isLandscape = size.width > size.height
        let titleSize: CGFloat  = isLandscape ? 44 : 50
        let bodySize: CGFloat   = isLandscape ? 22 : 26
        let bodyMaxWidth: CGFloat = isLandscape ? 680 : 760

        return VStack(spacing: 16) {
            Text("Layer Order")
                .font(.system(size: titleSize, weight: .bold, design: .rounded))

            Text("Tap and drag to reorder your layers.\nItems at the top of the list will appear in front of the canvas.")
                .font(.system(size: bodySize, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(maxWidth: bodyMaxWidth)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }

    // MARK: - "Tap anywhere to close" hint
    private var closeHint: some View {
        Text("Tap anywhere to close")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .opacity(0.6)
    }

    // MARK: - Fallback (shown when frame hasn't been captured yet)
    private var fallbackContent: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Layer Order")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Tap and drag to reorder your layers.")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Dismiss
    private func closeOnboarding() {
        withAnimation(.easeInOut) {
            hasLayerOnboarding = true
            showLayerOnboarding = false
        }
    }
}

#Preview {
    LayerOnboardingView(
        hasLayerOnboarding: .constant(false),
        showLayerOnboarding: .constant(true),
        toolButtonFrames: .constant([
            "layer": ToolButtonFramePreference(
                id: "layer",
                frame: CGRect(x: 720, y: 60, width: 44, height: 44),
                tooltipText: "Tap and drag to reorder layers"
            )
        ])
    )
}
