//
//  ComposeCardView.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//

import SwiftUI

struct ComposeCardView: View {
    var body: some View {
        ZStack {
            Image("Letter_Front_PostCard_Emotion")
                .resizable()
                .scaledToFill()

            Text("Pen another story here...")
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.6))
                .padding(.horizontal, 12)
        }
        .aspectRatio(260.0 / 184.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
