//
//  PaperPeekView.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//

import SwiftUI

/// The paper itself, plus a short preview line shown once it has risen far
/// enough above the pocket to actually be legible.
struct PaperPeekView: View {
    let previewText: String
    let showText: Bool

    var body: some View {
        ZStack(alignment: .top) {
            Image("Paper_Pen_Another_Story_Here")
                .resizable()
                .scaledToFit()

            if showText {
                Text(previewText)
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.75))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 36)
                    .padding(.horizontal, 36)
                    .transition(.opacity)
            }
        }
    }
}
