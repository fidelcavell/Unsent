//
//  JournalDetailOnboardingView.swift
//  Postbox
//
//  Created by Codex on 12/08/26.
//

import SwiftUI

struct JournalDetailOnboardingView: View {
    @Binding var hasJournalDetailOnboarding: Bool
    @Binding var showJournalDetailOnboarding: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let isLandscape = size.width > size.height
            let sidePadding: CGFloat = isLandscape ? 56 : 48
            let textY = isLandscape ? size.height * 0.68 : size.height * 0.70

            ZStack {
                Color.black.opacity(0.58)
                    .ignoresSafeArea()

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(white: 0.42))
                    .frame(width: min(size.width * 0.72, 980), height: min(size.height * 0.90, 840))
                    .position(x: size.width / 2, y: size.height * 0.58)
                    .allowsHitTesting(false)

                onboardingPaperStackPreview(in: size)

                Text("Tap anywhere to close")
                    .font(.system(size: isLandscape ? 28 : 24, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.52))
                    .position(x: size.width / 2, y: isLandscape ? 60 : 72)

                HStack(alignment: .top) {
                    onboardingInstruction(
                        title: "Previous Page",
                        message: "Swipe right to revisit\nthe page before"
                    )

                    Spacer()

                    onboardingInstruction(
                        title: "Next Page",
                        message: "Swipe left to read the\nrest of your letter"
                    )
                }
                .padding(.horizontal, sidePadding)
                .position(x: size.width / 2, y: textY)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                closeDetailOnboarding()
            }
        }
    }

    private func onboardingPaperStackPreview(in size: CGSize) -> some View {
        let paperWidth: CGFloat = min(520, size.width * 0.38)
        let paperHeight = paperWidth * 1.34
        let centerY = size.height * 0.52
        let sideOffset = paperWidth * 0.22

        return ZStack {
            Image("halaman_surat_kosong")
                .resizable()
                .scaledToFit()
                .frame(width: paperWidth, height: paperHeight)
                .offset(x: -sideOffset)
                .opacity(0.82)
                .rotationEffect(.degrees(-10))

            Image("halaman_surat_kosong")
                .resizable()
                .scaledToFit()
                .frame(width: paperWidth, height: paperHeight)
                .offset(x: sideOffset)
                .opacity(0.82)
                .rotationEffect(.degrees(7))

            Image("halaman_surat_kosong")
                .resizable()
                .scaledToFit()
                .frame(width: paperWidth, height: paperHeight)
                .colorMultiply(Color(white: 0.74))
                .opacity(0.96)
        }
        .position(x: size.width / 2, y: centerY)
        .allowsHitTesting(false)
    }

    private func onboardingInstruction(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title)
                .font(.system(size: 42, weight: .bold, design: .rounded))

            Text(message)
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .lineSpacing(4)
        }
        .foregroundStyle(.white)
        .frame(width: 310, alignment: .leading)
    }

    private func closeDetailOnboarding() {
        withAnimation(.easeInOut) {
            hasJournalDetailOnboarding = true
            showJournalDetailOnboarding = false
        }
    }
}

#Preview(traits: .landscapeRight) {
    JournalDetailOnboardingView(
        hasJournalDetailOnboarding: .constant(false),
        showJournalDetailOnboarding: .constant(true)
    )
}
