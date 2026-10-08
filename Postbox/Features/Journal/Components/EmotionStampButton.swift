//
//  EmotionStampButton.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import SwiftUI

struct EmotionStampButton: View {
    @Binding var selectedImage: Image?          
    @State private var selectedEmotionName: String? = nil
    @State private var isEmotionPickerPresented = false
    
    var action: (() -> Bool)? = nil
    var isOnboarding: Bool = false
    
    private let stampContentOffset = CGSize(width: 24, height: 0)
    
    var body: some View {
        Button(action: {
            if action?() ?? true {
                isEmotionPickerPresented = true
            }
        }) {
            VStack(spacing: -8) {
                ZStack {
                    Image("emotion_stamp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                    
                    if let image = selectedImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .clipped()
                            .offset(stampContentOffset)
                    } else {
                        Image("button_plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .offset(stampContentOffset)
                    }
                }
                
                Text(selectedEmotionName ?? "Choose emotion")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(isOnboarding ? .white : .black)
                    .offset(stampContentOffset)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $isEmotionPickerPresented) {
            EmotionSelectionModal(selectedImage: $selectedImage, selectedEmotionName: $selectedEmotionName)
        }
    }
}

#Preview {
    EmotionStampButton(selectedImage: .constant(nil))  
}
