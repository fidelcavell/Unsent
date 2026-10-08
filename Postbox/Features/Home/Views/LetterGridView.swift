//
//  LetterGridView.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//

import SwiftUI

struct LetterGridView: View {
    let letters: [Letter]
    let isSelecting: Bool
    let selectedIDs: Set<UUID>
    let onTapLetter: (Letter) -> Void
    
    private let columnCount = 3
    private let gridSpacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 16
    private let cardAspectRatio: CGFloat = 1.41   // ≈ 310/220, matching LetterCardView's card frame
    
    @State private var showWritingScreen = false
    
    var body: some View {
        GeometryReader { outer in
            let totalSpacing = gridSpacing * CGFloat(columnCount - 1) + horizontalPadding * 2
            let columnWidth = (outer.size.width - totalSpacing) / CGFloat(columnCount)
            let cardHeight = columnWidth / cardAspectRatio
            let columns = Array(repeating: GridItem(.fixed(columnWidth), spacing: gridSpacing), count: columnCount)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: gridSpacing) {
                    ForEach(Array(letters.enumerated()), id: \.element.id) { index, letter in
                        gridCard(for: letter, isFirstLetter: index == 0)
                            .frame(width: columnWidth, height: cardHeight)
                            .clipped()
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 16)
            }
        }
        .navigationDestination(isPresented: $showWritingScreen) {
            JournalListView()
        }
    }
    
    private func gridCard(for letter: Letter, isFirstLetter: Bool) -> some View {
        let isSelected = selectedIDs.contains(letter.id)
        
        return Group {
            if isFirstLetter, !isSelecting {
                NavigationLink {
                    LetterPeekScreen(
                        entry: letter.entry,
                        autoOpen: true
                    ) {
                        showWritingScreen = true
                    }
                } label: {
                    gridCardContent(for: letter, isSelected: isSelected)
                }
                .buttonStyle(PressScaleButtonStyle())
            } else {
                Button {
                    onTapLetter(letter)
                } label: {
                    gridCardContent(for: letter, isSelected: isSelected)
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }
    
    private func gridCardContent(for letter: Letter, isSelected: Bool) -> some View {
        Group {
            if letter.id == letters.first?.id && !isSelecting {
                FirstLetterPeekCard(letter: letter)
            } else {
                LetterCardView(
                    letter: letter,
                    isLifted: isSelecting && isSelected,
                    isSelecting: isSelecting,
                    isSelected: isSelected,
                    selectionCheckmarkPlacement: .bottom
                )
            }
        }
        .scaleEffect(isSelecting && isSelected ? 1.08 : 1)
        .zIndex(isSelected ? 2 : 0)
    }
}

struct FirstLetterPeekCard: View {
    let letter: Letter
    
    @StateObject private var viewModel: LetterOpenViewModel
    @State private var hasOpened = false
    
    // The envelope's natural, un-scaled content size — adjust these two
    // numbers if the shape still doesn't fit; see note below.
    private let baseSize = CGSize(width: 300, height: 340)
    
    // Extra shrink on top of the fit-to-box scale, for a touch of breathing room.
    private let fillFraction: CGFloat = 0.99
    
    init(letter: Letter) {
        self.letter = letter
        _viewModel = StateObject(wrappedValue: LetterOpenViewModel(entry: letter.entry))
    }
    
    var body: some View {
        GeometryReader { proxy in
            let fitScale = min(
                proxy.size.width / baseSize.width,
                proxy.size.height / baseSize.height
            ) * fillFraction
            
            EnvelopeOpenCardView(
                closedOpacity: viewModel.closedOpacity,
                closedScale: viewModel.closedScale,
                openStackOpacity: viewModel.openStackOpacity,
                paperOffset: viewModel.paperOffset,
                paperOpacity: viewModel.paperOpacity,
                previewText: viewModel.entry.previewText,
                showPeekText: viewModel.showPeekText
            )
            .frame(width: baseSize.width, height: baseSize.height)
            .padding(.bottom, 35)
            .scaleEffect(fitScale, anchor: .bottom)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
        }
        .onAppear {
            guard !hasOpened else { return }
            hasOpened = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.open()
            }
        }
    }
}

private extension Letter {
    var entry: LetterEntry {
        LetterEntry(
            id: id,
            title: title,
            date: date,
            previewText: content,
            fullContent: content
        )
    }
}
