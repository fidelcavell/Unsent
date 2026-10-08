import SwiftUI

struct LetterPeekScreen: View {
    @StateObject private var viewModel: LetterOpenViewModel
    @State private var hasAutoOpened = false
    let autoOpen: Bool
    let startsOpened: Bool
    let onStartWriting: (() -> Void)?

    init(
        entry: LetterEntry,
        autoOpen: Bool = false,
        startsOpened: Bool = false,
        onStartWriting: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: LetterOpenViewModel(entry: entry))
        self.autoOpen = autoOpen
        self.startsOpened = startsOpened
        self.onStartWriting = onStartWriting
    }

    var body: some View {
        VStack(spacing: 24) {
            LetterPeekCard(
                entry: viewModel.entry,
                autoOpen: autoOpen,
                startsOpened: startsOpened
            ) {
                onStartWriting?()
            }

            Text(viewModel.isOpen
                 ? "Tap to write"
                 : "Tap the letter to start journaling.")
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LetterPeekScreen(
        entry: LetterEntry(
            title: "Write your first story",
            date: .now,
            previewText: "Today was one of those quiet, steady days that surprisingly left a big smile on my face...",
            fullContent: "Full diary content goes here."
        )
    )
}
