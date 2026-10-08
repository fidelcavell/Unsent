//
//  EmotionStampOnboardingView.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import SwiftUI

struct EmotionStampOnboardingView: View {
    @Binding var hasEmotionStampOnboarding: Bool
    @Binding var showEmotionStampOnboarding: Bool
    @Binding var toolButtonFrames: [String: ToolButtonFramePreference]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Spacer()
                
                Text("What are you feeling right now?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Choose the emotion that feels closest to you \nat this moment. You can change it anytime.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                
                
                Spacer()
                
                Text("Tap anywhere to close")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .opacity(0.6)
                    .padding(.bottom, 120)
            }
            .foregroundStyle(.white)
        }
        .zIndex(4)
        .onTapGesture {
            withAnimation(.easeInOut) {
                hasEmotionStampOnboarding = true
                showEmotionStampOnboarding = false
            }
        }
        
        if toolButtonFrames["emotionStamp"] != nil {
            EmotionStampButton(selectedImage: .constant(nil), action: { false }, isOnboarding: true)
                .position(x: 1075, y: 220)
                .zIndex(5)
        }    }
}

#Preview {
    EmotionStampOnboardingView(
        hasEmotionStampOnboarding: .constant(true),
        showEmotionStampOnboarding: .constant(true),
        toolButtonFrames: .constant([
            "emotionStamp": ToolButtonFramePreference(
                id: "emotionStamp",
                frame: CGRect(x: 0, y: 0, width: 100, height: 44),
                tooltipText: "Save changes"
            )
        ])
    )
}
