//
//  MagicPenOnboardingView.swift
//  Postbox
//
//  Created by Valentino Hartanto on 12/08/26.
//

import SwiftUI

struct MagicPenOnboardingView: View {
    @Binding var hasMagicPenOnboarding: Bool
    @Binding var showMagicPenOnboarding: Bool
    @Binding var toolButtonFrames: [String: ToolButtonFramePreference]
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeOnboarding()
                    }

                if let pref = toolButtonFrames["magicPen"] {
                    highlightedButton(at: pref.frame)
                    buttonCaption(at: pref.frame)

                    VStack(spacing: 0) {
                        promptRow(in: proxy.size)
                            .padding(.top, promptTopPadding(in: proxy.size))

                        Spacer()
                            .frame(height: promptTitleSpacing(in: proxy.size))

                        titleBlock(in: proxy.size)

                        Spacer()

                        closeHint
                            .padding(.bottom, 120)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .zIndex(6)
                } else {
                    fallbackContent
                }
            }
        }
        .zIndex(4)
    }

    private func highlightedButton(at frame: CGRect) -> some View {
        let buttonSize = max(frame.width, frame.height)

        return Image("button_magicpen")
            .resizable()
            .scaledToFit()
            .frame(width: buttonSize, height: buttonSize)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
            .position(x: frame.midX, y: frame.midY)
            .allowsHitTesting(false)
            .zIndex(5)
    }

    private func buttonCaption(at frame: CGRect) -> some View {
        let captionY = frame.maxY + 34

        return Text("Tap this button again\nto hide the idea")
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .frame(width: 180)
            .position(x: frame.midX, y: captionY)
            .allowsHitTesting(false)
            .zIndex(5)
    }

    private var closeHint: some View {
        Text("Tap anywhere to close")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .opacity(0.6)
    }

    private func promptTopPadding(in size: CGSize) -> CGFloat {
        let isLandscape = size.width > size.height
        return isLandscape ? min(max(size.height * 0.28, 184), 220) : min(max(size.height * 0.22, 188), 240)
    }

    private func promptTitleSpacing(in size: CGSize) -> CGFloat {
        size.width > size.height ? 76 : 96
    }

    private func promptRow(in size: CGSize) -> some View {
        let isLandscape = size.width > size.height
        let boxWidth = isLandscape ? min(450, size.width * 0.41) : min(620, size.width * 0.60)
        let sideTextWidth = isLandscape ? min(250, size.width * 0.22) : min(290, size.width * 0.28)

        return HStack(alignment: .center, spacing: 16) {
            Image("onboardingBox")
                .resizable()
                .scaledToFit()
                .frame(width: boxWidth)

            Text("You can “refresh” to get another\nprompt related to your feeling")
                .font(.system(size: isLandscape ? 19 : 22, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .frame(width: sideTextWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .offset(x: isLandscape ? 14 : 8)
        .zIndex(6)
    }

    private func titleBlock(in size: CGSize) -> some View {
        let isLandscape = size.width > size.height
        let titleSize: CGFloat = isLandscape ? 44 : 50
        let subtitleSize: CGFloat = isLandscape ? 28 : 32
        let bodySize: CGFloat = isLandscape ? 22 : 26
        let bodyMaxWidth: CGFloat = isLandscape ? 760 : 820

        return VStack(spacing: 16) {
            Text("Writing Helper")
                .font(.system(size: titleSize, weight: .bold, design: .rounded))

            Text("Not sure what to write?")
                .font(.system(size: subtitleSize, weight: .medium, design: .rounded))

            Text("We’ll give you a general writing idea to get started.\nOnce you choose an emotion, the idea will become more specific to how you feel")
                .font(.system(size: bodySize, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(maxWidth: bodyMaxWidth)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }
    
    private var fallbackContent: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Writing Helper")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Tap the magic pen to get a writing prompt.")
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func closeOnboarding() {
        withAnimation(.easeInOut) {
            hasMagicPenOnboarding = true
            showMagicPenOnboarding = false
        }
    }
}

#Preview {
    MagicPenOnboardingView(
        hasMagicPenOnboarding: .constant(true),
        showMagicPenOnboarding: .constant(true),
        toolButtonFrames: .constant([
            "magicPen": ToolButtonFramePreference(
                id: "magicPen",
                frame: CGRect(x: 800, y: 100, width: 60, height: 60),
                tooltipText: "Tap here to get a writing idea"
            )
        ])
    )
}
