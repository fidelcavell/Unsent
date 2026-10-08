//
//  LetterPeekCard.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//


import SwiftUI

struct LetterPeekCard: View {
    @StateObject private var viewModel: LetterOpenViewModel

    let autoOpen: Bool
    let onTap: (() -> Void)?

    @State private var hasAutoOpened = false

    init(
        entry: LetterEntry,
        autoOpen: Bool = false,
        startsOpened: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: LetterOpenViewModel(entry: entry, startsOpened: startsOpened)
        )
        self.autoOpen = autoOpen
        self.onTap = onTap
    }
    
    var body: some View {
        EnvelopeOpenCardView(
            closedOpacity: viewModel.closedOpacity,
            closedScale: viewModel.closedScale,
            openStackOpacity: viewModel.openStackOpacity,
            paperOffset: viewModel.paperOffset,
            paperOpacity: viewModel.paperOpacity,
            previewText: viewModel.entry.previewText,
            showPeekText: viewModel.showPeekText
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.isOpen {
                onTap?()
            } else {
                viewModel.toggleOpen()
            }
        }
        .onAppear {
            if autoOpen && !hasAutoOpened {
                hasAutoOpened = true
                viewModel.open()
            }
        }
    }
}
