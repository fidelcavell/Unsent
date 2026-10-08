//
//  LetterStackView.swift
//  Postbox
//
//  Created by Theona Arlinton on 10/08/26.
//

import SwiftUI

struct LetterStackView: View {
    let letters: [Letter]
    let isSelecting: Bool
    let selectedIDs: Set<UUID>
    let onTapLetter: (Letter) -> Void
    let onLongPressLetter: (Letter) -> Void
    let onReachedBottom: () -> Void

    // Increased from the original 56/88, but pulled back from a full
    // 2x (112/176) — that pushed the fan far enough off-center that
    // it drifted into the corner of the screen instead of staying
    // centered behind the peek card.
    private let stepX: CGFloat = 70
    private let stepY: CGFloat = 80

    private let loadTriggerDistance = 6

    // Show a maximum of 4 items in the deck at once.
    private let visibleStackCount = 4

    // Increased slightly so each card visibly shrinks more as it
    // sits further back in the stack.
    private let scaleFalloff: CGFloat = 0.25
    private let opacityFalloff: CGFloat = 0.25
    private let minScale: CGFloat = 0.78
    private let minOpacity: CGFloat = 0.52

    // Regular letter cards (roughly 2x the original size)
    private let cardWidth: CGFloat = 540
    private let cardHeight: CGFloat = 350

    // Initial LetterPeekScreen — matched to the card frame so its
    // resting position lines up exactly with where card index 0
    // sits. (A larger, mismatched frame here was the cause of the
    // peek drifting away from the stack: LetterPeekCard doesn't sit
    // flush against the top of its container, so scaling a tall,
    // top-anchored frame pushed the visible envelope further and
    // further down as it grew.)
    private let peekWidth: CGFloat = 640
    private let peekHeight: CGFloat = 460

    // LetterPeekCard has its own fixed intrinsic size internally, so
    // just enlarging the frame above only adds empty space around it.
    // This extra multiplier actually scales the rendered content up,
    // growing outward from its own center so it stays anchored to
    // its offset position instead of drifting.
    private let peekContentScale: CGFloat = 1.4

    // The peek card (relative == 0) is meant to be the visual focal
    // point — front and center — with the rest of the stack fanning
    // out behind it. Averaging across the whole stack (as before)
    // pulled the center of focus toward the back cards instead, and
    // left the cluster sitting too low. This anchors on the peek's
    // own position and adds a fixed upward lift so it sits higher
    // in the available space.
    private let clusterVerticalLift: CGFloat = 0

    private var clusterCenterOffset: CGSize {
        CGSize(width: 0, height: -clusterVerticalLift)
    }
    
    @State private var committedScrollIndex: CGFloat = 0
    @GestureState private var dragTranslation: CGFloat = 0
    @State private var showWritingScreen = false
    
    var body: some View {
        GeometryReader { proxy in
            
            let scrollIndex = clampedScrollIndex(
                committedScrollIndex
                + dragTranslation / stepY
            )
            
            ZStack {
                
                // -------------------------------------------------
                // INITIAL PEEK
                //
                // Exists ONLY while the user is at the very
                // beginning of the stack.
                // -------------------------------------------------
                
                if scrollIndex < 1,
                   !letters.isEmpty,
                   !isSelecting {
                    
                    peekCardView(
                        scrollIndex: scrollIndex
                    )
                }
                
                // -------------------------------------------------
                // NORMAL LETTER CARDS
                // -------------------------------------------------
                
                ForEach(
                    visibleLetterIndices(
                        scrollIndex: scrollIndex
                    ),
                    id: \.self
                ) { index in
                    
                    letterCardView(
                        at: index,
                        scrollIndex: scrollIndex
                    )
                }
            }
            .frame(
                width: proxy.size.width,
                height: proxy.size.height
            )
            .contentShape(Rectangle())
            .clipped()
            .simultaneousGesture(
                scrollGesture(
                    scrollIndex: scrollIndex
                )
            )
        }
        .navigationDestination(
            isPresented: $showWritingScreen
        ) {
            JournalListView()
        }
    }
    
    // MARK: - Scroll Gesture
    
    private func scrollGesture(
        scrollIndex: CGFloat
    ) -> some Gesture {
        
        DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                
                let delta =
                value.translation.height / stepY
                
                committedScrollIndex =
                clampedScrollIndex(
                    committedScrollIndex + delta
                )
                
                checkLoadMore(
                    scrollIndex: committedScrollIndex
                )
            }
    }
    
    // MARK: - Scroll Index
    
    private func clampedScrollIndex(
        _ raw: CGFloat
    ) -> CGFloat {
        
        max(
            0,
            min(
                raw,
                CGFloat(max(letters.count - 1, 0))
            )
        )
    }
    
    // MARK: - Visible Letter Cards
    
    private func visibleLetterIndices(
        scrollIndex: CGFloat
    ) -> [Int] {
        
        guard !letters.isEmpty else {
            return []
        }
        
        // -----------------------------------------------
        // Initial state (visibleStackCount == 4):
        //
        // Peek
        // Letter 0
        // Letter 1
        // Letter 2
        //
        // After scroll #1:
        //
        // Letter 1
        // Letter 2
        // Letter 3
        // Letter 4
        // -----------------------------------------------
        
        let start: Int
        
        if scrollIndex < 1 {
            // Peek occupies the first slot,
            // so only (visibleStackCount - 1) regular cards are shown.
            start = 0
        } else {
            // Once Peek disappears, the scroll index maps
            // directly to the first visible letter.
            start = Int(scrollIndex.rounded(.down))
        }
        
        let count =
        scrollIndex < 1
        ? visibleStackCount - 1
        : visibleStackCount
        
        let end = min(
            letters.count,
            start + count
        )
        
        guard start < end else {
            return []
        }
        
        return Array(start..<end)
    }
    
    // MARK: - Letter Card
    
    private func letterCardView(
        at index: Int,
        scrollIndex: CGFloat
    ) -> some View {
        
        let letter = letters[index]
        
        // Before the first scroll, letters are positioned
        // behind the Peek.
        //
        // After the first scroll, they become the normal
        let relative: CGFloat
        
        if scrollIndex < 1 {
            
            // Letter 0 is directly behind Peek.
            relative =
            CGFloat(index + 1)
            - scrollIndex
            
        } else {
            
            relative =
            CGFloat(index) - scrollIndex
        }
        
        let distance =
        abs(relative)
        
        let scale = max(
            minScale,
            1 - distance * scaleFalloff
        )
        
        let opacity = max(
            minOpacity,
            1 - distance * opacityFalloff
        )
        
        let isSelected =
        selectedIDs.contains(letter.id)
        
        return Button {
            
            onTapLetter(letter)
            
        } label: {
            
            LetterCardView(
                letter: letter,
                isLifted: false,
                isSelecting: isSelecting,
                isSelected: isSelected
            )
        }
        .buttonStyle(
            PressScaleButtonStyle()
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.4)
                .onEnded { _ in
                    onLongPressLetter(letter)
                }
        )
        .frame(
            width: cardWidth,
            height: cardHeight
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(
            x: relative * stepX + clusterCenterOffset.width,
            y: -relative * stepY + clusterCenterOffset.height
        )
        .zIndex(
            Double(letters.count - index)
        )
    }
    
    // MARK: - Initial Peek
    
    private func peekCardView(
        scrollIndex: CGFloat
    ) -> some View {
        
        let distance = abs(scrollIndex)
        
        let shrinkProgress = min(
            distance / 0.5,
            1
        )
        
        let width =
        peekWidth
        - (peekWidth - cardWidth)
        * shrinkProgress
        
        let height =
            peekHeight
            - (peekHeight - cardHeight)
            * shrinkProgress

        let swipeScale = max(
            minScale,
            1 - distance * scaleFalloff
        )

        // Combine the swipe-driven falloff with the fixed content
        // multiplier so the card is both responsive to dragging AND
        // rendered visibly larger than its default intrinsic size.
        let scale = swipeScale * peekContentScale

        let opacity = max(
            minOpacity,
            1 - distance * opacityFalloff
        )
        
        return LetterPeekScreen(
            entry: letters[0].entry,
            autoOpen: true,
            startsOpened: false
        ) {
            showWritingScreen = true
        }
        .id("initial-letter-peek")
        .frame(
            width: width,
            height: height
        )
        .scaleEffect(scale, anchor: .center)
        .opacity(opacity)
        .offset(
            x: -scrollIndex * stepX + clusterCenterOffset.width,
            y: scrollIndex * stepY + clusterCenterOffset.height
        )
        .zIndex(
            Double(letters.count + 1000)
        )
    }
    
    // MARK: - Load More
    
    private func checkLoadMore(
        scrollIndex: CGFloat
    ) {
        
        if CGFloat(letters.count) - scrollIndex
            <= CGFloat(loadTriggerDistance) {
            
            onReachedBottom()
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
