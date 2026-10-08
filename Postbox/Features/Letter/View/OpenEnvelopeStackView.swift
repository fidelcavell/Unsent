//
//  OpenEnvelopeStackView.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//

import SwiftUI

/// The opened stack, back-to-front: envelope back panel, the paper peeking
/// up in the middle, front pocket on top so the paper reads as tucked
/// inside it. Stateless — the container passes in already-computed values.
struct OpenEnvelopeStackView: View {
    let paperOffset: CGFloat
    let paperOpacity: Double
    let previewText: String
    let showPeekText: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            EnvelopeBackView()
                .frame(width: 300, height: 286)
                .offset(y: -28)

            PaperPeekView(previewText: previewText, showText: showPeekText)
                .frame(width: 242, height: 190)
                .offset(y: paperOffset)
                .opacity(paperOpacity)

            EnvelopeFrontPocketView()
                .frame(width: 300, height: 190)
        }
        .frame(width: 300, height: 250, alignment: .bottom)

    }
}
