//
//  WelcomeCanvasView.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import SwiftUI

struct WelcomeCanvasView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Welcome to Canvas")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This is your space to unload whatever's\non your mind. Free, no strict rules, and it\ndefinitely doesn't need to be neat")
                .font(.title3)

            Spacer()

            Text("Tap anywhere to continue")
                .font(.headline)
                .padding(.bottom, 120)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .allowsHitTesting(false)
    }
}

// MARK: - Notes: To show the preview, please remove foregroundStyle(.white)
#Preview {
    WelcomeCanvasView()
}
