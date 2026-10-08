//
//  ToolTipOnboardingView.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import SwiftUI

struct ToolTipOnboardingView: View {
    @Binding var hasToolOnboarding: Bool
    @Binding var showToolOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("Express yourself in your way")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 36)
                    .padding(.bottom)
                
                Text("You don’t always have to use words. Choose the way \nthat feels most comfortable for you")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            HStack(spacing: 8) {
                                ToolButton(id: "text", action: {}, assetName: "button_text", toolTipText: "", coordinateSpaceName: "none")
                                    .scaleEffect(1.3)
                                    .frame(width: 80, height: 80)
                                Text("Write down anything you want to say")
                                    .font(.title2)
                                    .fontWeight(.regular)
                            }
                            
                            HStack(spacing: 8) {
                                ToolButton(id: "scribble", action: {}, assetName: "button_pencil", toolTipText: "", coordinateSpaceName: "none")
                                    .scaleEffect(1.3)
                                    .frame(width: 80, height: 80)
                                Text("Scribble, draw, or write freely with your brush")
                                    .font(.title2)
                                    .fontWeight(.regular)
                            }
                            
                            HStack(spacing: 8) {
                                ToolButton(id: "photo", action: {}, assetName: "button_image", toolTipText: "", coordinateSpaceName: "none")
                                    .scaleEffect(1.3)
                                    .frame(width: 80, height: 80)
                                Text("Add a photo that captures part of your day")
                                    .font(.title2)
                                    .fontWeight(.regular)
                            }
                            
                            HStack(spacing: 8) {
                                ToolButton(id: "mic", action: {}, assetName: "button_mic", toolTipText: "", coordinateSpaceName: "none")
                                    .scaleEffect(1.3)
                                    .frame(width: 80, height: 80)
                                Text("Record your thoughts when speaking feels easier than writing")
                                    .font(.title2)
                                    .fontWeight(.regular)
                            }
                        }
                        .padding(.leading, 80)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("Tap anywhere to close")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .opacity(0.6)
                            
                            Spacer()
                        }
                        .padding(.bottom, 120)
                    }
                    
                    Spacer()
                }
            }
            .foregroundColor(.white)
        }
        .zIndex(4)
        .onTapGesture {
            withAnimation(.easeInOut) {
                hasToolOnboarding = true
                showToolOnboarding = false
            }
        }
    }
}

#Preview {
    ToolTipOnboardingView(
        hasToolOnboarding: .constant(true),
        showToolOnboarding: .constant(true),
    )
}
