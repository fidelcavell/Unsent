//
//  JournalNavOnboardingView.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import SwiftUI

struct JournalNavOnboardingView: View {
    @Binding var hasNavOnboarding: Bool
    @Binding var showNavOnboarding: Bool
    @Binding var toolButtonFrames: [String: ToolButtonFramePreference]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
        }
        .zIndex(4)
        .onTapGesture {
            withAnimation(.easeInOut) {
                hasNavOnboarding = true
                showNavOnboarding = false
            }
        }
        
        // Left nav button highlight
        if let pref = toolButtonFrames["navBack"] {
            JournalNavButton(
                assetName: "button_back",
                buttonTitle: "",
                xImageAsset: 72,
                yImageAsset: -210,
                xnavButton: -640,
                ynavButton: 600,
                degree: 4,
                action: {}
            )
            .position(x: pref.frame.midX, y: pref.frame.midY)
            .allowsHitTesting(false)
            .zIndex(5)
            
            VStack(spacing: 16) {
                Text("Previous Page")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Tap or Swipe here to revisit \nthe previous page")
                    .font(.title3)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .position(x: 220, y: 580)
            .zIndex(6)
        }
        
        VStack {
            Spacer()
            Text("Tap anywhere to close")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 120)
        }
        .zIndex(6)
        
        // Right nav button highlight
        if let pref = toolButtonFrames["navForward"] {
            JournalNavButton(
                assetName: "button_plus",
                buttonTitle: "",
                xImageAsset: -72,
                yImageAsset: -210,
                xnavButton: 630,
                ynavButton: 600,
                degree: 4,
                action: {}
            )
            .position(x: pref.frame.midX, y: pref.frame.midY)
            .allowsHitTesting(false)
            .zIndex(5)
            
            VStack(spacing: 16) {
                Text("Add New Page")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Tap or Swipe here to add a new page \nwhen there’s more you want to say")
                    .font(.title3)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .position(x: 1150, y: 580)
            .zIndex(6)
        }
    }
}

#Preview {
    JournalNavOnboardingView(
        hasNavOnboarding: .constant(true),
        showNavOnboarding: .constant(true),
        toolButtonFrames: .constant([
            "navForward": ToolButtonFramePreference(
                id: "navForward",
                frame: CGRect(x: 0, y: 0, width: 100, height: 44),
                tooltipText: "Save changes"
            ),
            "navBack": ToolButtonFramePreference(
                id: "navBack",
                frame: CGRect(x: 0, y: 0, width: 100, height: 44),
                tooltipText: "Save changes"
            )
        ])
    )
}
