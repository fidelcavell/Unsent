//
//  EmotionSelectionModal.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import SwiftUI
import UIKit

/// A base color category and the specific emotions it expands into.
/// Specific emotions are arranged in a 1-3-1 layout (top / middle / bottom).
struct EmotionCategory: Identifiable {
    let id: String
    let displayName: String
    let question: String
    let folder: String
    let baseAsset: String
    let tint: Color
    let top: String
    let middle: [String]
    let bottom: String
    
    static let overwhelmed = EmotionCategory(
        id: "overwhelmed",
        displayName: "Overwhelmed\n& Uncomfortable",
        question: "Which of these feels closest to\nyour discomfort?",
        folder: "Emotion/Overwhelmed&Uncomfortable",
        baseAsset: "Emotion/Overwhelmed&Uncomfortable/BaseRed",
        tint: .red,
        top: "Angry",
        middle: ["Frustated", "Annoyed", "Overwhelmed"],
        bottom: "Determined"
    )
    
    static let energetic = EmotionCategory(
        id: "energetic",
        displayName: "Energetic\n& Excited",
        question: "Which of these feels closest to\nyour energy?",
        folder: "Emotion/Energetic&Excited",
        baseAsset: "Emotion/Energetic&Excited/BaseYellow",
        tint: .yellow,
        top: "Determined",
        middle: ["Confident", "Content", "Satisfied"],
        bottom: "Happy"
    )
    
    static let drained = EmotionCategory(
        id: "drained",
        displayName: "Drained\n& Heavy",
        question: "Which of these feels closest to\nyour heaviness?",
        folder: "Emotion/Drained&Heavy",
        baseAsset: "Emotion/Drained&Heavy/BaseBlue",
        tint: .blue,
        top: "Sad",
        middle: ["Overwhelmed", "Lonely", "Drained"],
        bottom: "Hopeful"
    )
    
    static let calm = EmotionCategory(
        id: "calm",
        displayName: "Calm &\nPeaceful",
        question: "Which of these feels closest to\nyour calm?",
        folder: "Emotion/Calm&Peaceful",
        baseAsset: "Emotion/Calm&Peaceful/BaseGreen",
        tint: .green,
        top: "Hopeful",
        middle: ["satisfied", "Calm", "Peaceful"],
        bottom: "Grateful"
    )
}

/// A two-step modal for picking a feeling:
/// Step 1 shows the 5 base emotions in a cross layout with text descriptions.
/// Step 2 (only for colored bases) shows that color's specific emotions in a 1-3-1 layout with emotion labels.
struct EmotionSelectionModal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImage: Image?
    @Binding var selectedEmotionName: String?
    
    @State private var stage: Stage = .base
    @State private var cardRevealed = false
    @Namespace private var modalNamespace
    
    private enum Stage {
        case base
        case detail(EmotionCategory)
    }
    
    private let neutralAsset = "Emotion/Neutral"
    private let modalBackgroundAsset = "Emotion/BaseModal"
    
    private var isDetail: Bool {
        if case .detail = stage { return true }
        return false
    }
    
    private var titleText: String {
        if case .detail(let category) = stage {
            return category.question
        }
        return "How are you feeling right now?"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            GeometryReader { proxy in
                card(fitIn: proxy.size)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.hidden)
        .onChange(of: cardRevealed) { _, newValue in
            if !newValue {
                dismiss()
            }
        }
    }
    
    // MARK: - Card
    
    private func card(fitIn available: CGSize) -> some View {
        let bgAsset = EmotionImage.resolvedName(for: modalBackgroundAsset)
        let cardWidth = min(available.width * 0.78, available.height * 1.55)
        let cardHeight = min(available.height * 0.78, cardWidth * 0.68)
        let emotionAreaHeight = isDetail ? min(430, cardHeight * 0.64) : min(360, cardHeight * 0.58)
        
        return ZStack {
            Image(bgAsset)
                .resizable()
                .scaledToFill()
                .frame(width: cardWidth, height: cardHeight)
                .clipped()
            
            VStack(spacing: 0) {
                header
                    .padding(.top, cardHeight * 0.16)
                    .padding(.horizontal, cardWidth * 0.12)
                
                Spacer(minLength: 0)
                
                emotionArea
                    .frame(height: emotionAreaHeight)
                    .padding(.bottom, cardHeight * 0.1)
                    .padding(.horizontal, cardWidth * 0.12)
                
                Spacer(minLength: 0)
            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .opacity(cardRevealed ? 1 : 0)
        .scaleEffect(cardRevealed ? 1 : 0.85)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                cardRevealed = true
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        ZStack {
            Text(titleText)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
            
            HStack {
                if isDetail {
                    customButton(assetName: "button_back") {
                        stage = .base
                    }
                } else {
                    customButton(assetName: "button_silang") {
                        cardRevealed = false
                    }
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func customButton(assetName: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)) {
                action()
            }
        } label: {
            headerIcon(assetName)
        }
        .buttonStyle(.plain)
    }
    
    private func headerIcon(_ assetName: String) -> some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(width: 72, height: 72)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
    }
    
    // MARK: - Emotion Area (switches between base and detail)
    
    private var emotionArea: some View {
        GeometryReader { geo in
            let designWidth: CGFloat = isDetail ? 560 : 440
            let designHeight: CGFloat = isDetail ? 420 : 360
            let scale = min(geo.size.width / designWidth, geo.size.height / designHeight, 1)
            
            Group {
                switch stage {
                case .base:
                    baseSelectionView
                        .transition(baseTransition)
                case .detail(let category):
                    detailSelectionView(category)
                        .transition(detailTransition)
                }
            }
            .frame(width: designWidth, height: designHeight)
            .scaleEffect(scale)
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    private var baseTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.92)),
            removal: .opacity
        )
    }
    
    private var detailTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity
        )
    }
    
    // MARK: - Step 1: Base emotions (cross layout with text)
    
    private var baseSelectionView: some View {
        ZStack {
            baseButton(.overwhelmed).position(x: 100, y: 80)
            baseButton(.energetic).position(x: 340, y: 80)
            baseButton(.drained).position(x: 100, y: 280)
            baseButton(.calm).position(x: 340, y: 280)
            neutralButton.position(x: 220, y: 180)
        }
        .frame(width: 440, height: 360)
    }
    
    private func baseButton(_ category: EmotionCategory) -> some View {
        Button {
            selectBase(category)
        } label: {
            VStack(spacing: 6) {
                EmotionImage(assetPath: category.baseAsset, size: 72)
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140)
            }
        }
        .buttonStyle(EmotionPressableButtonStyle())
        .matchedGeometryEffect(id: category.id, in: modalNamespace, properties: .frame)
    }
    
    private var neutralButton: some View {
        Button {
            selectedImage = Image(EmotionImage.resolvedName(for: neutralAsset))
            selectedEmotionName = "Neutral"
            dismiss()
        } label: {
            VStack(spacing: 6) {
                EmotionImage(assetPath: neutralAsset, size: 84)
                Text("Neutral")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(EmotionPressableButtonStyle())
    }
    
    private func selectBase(_ category: EmotionCategory) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.72, blendDuration: 0.2)) {
            stage = .detail(category)
        }
    }
    
    // MARK: - Step 2: Specific emotions (1-3-1 layout with labels)
    
    private func detailSelectionView(_ category: EmotionCategory) -> some View {
        EmotionDetailGridView(category: category) { image, name in
            selectedImage = image
            selectedEmotionName = name
            dismiss()
        }
        .frame(width: 560, height: 420)
    }
}

/// The 1-3-1 grid of specific emotions with emotion text labels.
struct EmotionDetailGridView: View {
    let category: EmotionCategory
    let onSelect: (Image, String) -> Void
    
    @State private var revealed = false
    
    var body: some View {
        VStack(spacing: 22) {
            emotionButton(name: category.top, index: 0)
            HStack(spacing: 52) {
                emotionButton(name: category.middle[0], index: 1)
                emotionButton(name: category.middle[1], index: 2)
                emotionButton(name: category.middle[2], index: 3)
            }
            emotionButton(name: category.bottom, index: 4)
        }
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.2)) {
                    revealed = true
                }
            }
        }
    }
    
    private func emotionButton(name: String, index: Int) -> some View {
        Button {
            onSelect(Image(EmotionImage.resolvedName(for: "\(category.folder)/\(name)")), displayName(for: name))
        } label: {
            VStack(spacing: 6) {
                EmotionImage(assetPath: "\(category.folder)/\(name)", size: 82)
                Text(displayName(for: name))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 130)
            }
        }
        .buttonStyle(EmotionPressableButtonStyle())
        .opacity(revealed ? 1 : 0)
        .scaleEffect(revealed ? 1 : 0.2)
        .offset(y: revealed ? 0 : 20)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.6, blendDuration: 0.25)
            .delay(Double(index) * 0.055),
            value: revealed
        )
    }
    
    private func displayName(for name: String) -> String {
        if name.lowercased() == "frustated" {
            return "Frustrated"
        }
        return name.capitalized
    }
}

/// Loads an emotion asset by its full path or namespaced path, falling back
/// to shorter names so the image resolves without console warnings regardless
/// of whether "Assets/" was included in the path string.
struct EmotionImage: View {
    let assetPath: String
    let size: CGFloat
    
    var body: some View {
        Image(Self.resolvedName(for: assetPath))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
    }
    
    static func resolvedName(for path: String) -> String {
        if UIImage(named: path) != nil { return path }
        let parts = path.split(separator: "/")
        for i in 1..<parts.count {
            let candidate = parts[i...].joined(separator: "/")
            if UIImage(named: candidate) != nil { return candidate }
        }
        return path
    }
}

/// A small press-down bounce used by all emotion buttons.
struct EmotionPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    EmotionSelectionModal(selectedImage: .constant(nil), selectedEmotionName: .constant(nil))
}
