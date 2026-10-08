import SwiftUI
internal import Combine

@MainActor
final class LetterOpenViewModel: ObservableObject {
    let entry: LetterEntry

    @Published private(set) var isOpen = false

    // Closed envelope
    @Published private(set) var closedOpacity: Double = 1
    @Published private(set) var closedScale: CGFloat = 1

    // Opened stack
    @Published private(set) var openStackOpacity: Double = 0
    @Published private(set) var paperOffset: CGFloat = 40
    @Published private(set) var paperOpacity: Double = 0
    @Published private(set) var showPeekText = false

    init(entry: LetterEntry, startsOpened: Bool = false) {
        self.entry = entry
        guard startsOpened else { return }

        // Jump straight to the fully-open state, no animation —
        // this runs before the view ever appears.
        isOpen = true
        closedOpacity = 0
        closedScale = 0.94
        openStackOpacity = 1
        paperOffset = -48
        paperOpacity = 1
        showPeekText = true
    }
    func toggleOpen() {
        isOpen ? close() : open()
    }

    func open() {
        guard !isOpen else { return }
        isOpen = true

        // Quick tactile "press" pop before the closed envelope disappears.
        withAnimation(.easeOut(duration: 0.12)) {
            closedScale = 1.05
        }
        withAnimation(.easeIn(duration: 0.22).delay(0.1)) {
            closedOpacity = 0
            closedScale = 0.94
        }

        withAnimation(.easeOut(duration: 0.25).delay(0.15)) {
            openStackOpacity = 1
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.2)) {
            paperOffset = -48
            paperOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.25).delay(0.5)) {
            showPeekText = true
        }
    }

    func close() {
        guard isOpen else { return }
        isOpen = false

        withAnimation(.easeIn(duration: 0.2)) {
            showPeekText = false
        }
        withAnimation(.easeInOut(duration: 0.25).delay(0.05)) {
            paperOffset = 40
            paperOpacity = 0
        }
        withAnimation(.easeInOut(duration: 0.2).delay(0.2)) {
            openStackOpacity = 0
        }
        withAnimation(.easeOut(duration: 0.25).delay(0.3)) {
            closedOpacity = 1
            closedScale = 1
        }
    }
}
