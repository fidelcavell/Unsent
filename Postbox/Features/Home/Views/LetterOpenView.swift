//
//  LetterOpenView.swift
//  Postbox
//
//  Created by Theona Arlinton on 10/08/26.
//

import SwiftUI

struct LetterOpenView: View {
    let letter: Letter
    let onClose: () -> Void

    @State private var sealBroken = false
    @State private var paperRisen = false
    @State private var contentVisible = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: close) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .background(Circle().fill(Color(white: 0.93)))
                }
                Spacer()
            }
            .padding()

            ZStack(alignment: .top) {
                // Envelope back stays put; the seal breaks and the paper rises out of it.
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(white: 0.97))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.75), lineWidth: 1.5))
                    .frame(width: 320, height: 180)

                paperContent
                    .frame(width: 300, height: paperRisen ? 420 : 150)
                    .offset(y: paperRisen ? -140 : 20)

                Circle()
                    .fill(letter.sealColor)
                    .frame(width: 34, height: 34)
                    .scaleEffect(sealBroken ? 0.1 : 1)
                    .opacity(sealBroken ? 0 : 1)
                    .offset(y: 20)
            }

            Spacer()
        }
        .onAppear(perform: runOpenSequence)
    }

    private var paperContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(letter.date, format: .dateTime.day().month(.wide).year())
                .font(.system(size: 12))
                .foregroundColor(.gray)
            Text("Dear\nFuture Me")
                .font(.system(size: 14, weight: .semibold))
            if contentVisible {
                Text(letter.content)
                    .font(.system(size: 13))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.6), lineWidth: 1.2))
    }

    private func runOpenSequence() {
        withAnimation(.easeOut(duration: 0.25)) { sealBroken = true }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.15)) { paperRisen = true }
        withAnimation(.easeIn(duration: 0.3).delay(0.4)) { contentVisible = true }
    }

    private func close() {
        withAnimation(.easeInOut(duration: 0.2)) {
            sealBroken = false
            paperRisen = false
            contentVisible = false
        }
        onClose()
    }
}
