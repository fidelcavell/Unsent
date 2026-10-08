//
//  DiaryStore.swift
//  Postbox
//
//  Created by Theona Arlinton on 10/08/26.

import SwiftUI
internal import Combine

enum LetterSortOrder: String, CaseIterable {
    case newestFirst
    case oldestFirst
}

@MainActor
final class DiaryStore: ObservableObject {
    @Published private(set) var letters: [Letter] = []
    @Published var sortOrder: LetterSortOrder = .newestFirst
    @Published var dateRange: ClosedRange<Date>?

    @Published var isSelecting = false
    @Published var selectedIDs: Set<UUID> = []

    // Fixed to a small sample set for now — 6 letters, no pagination.
    // When there's a real data source behind this, swap `loadNextPage`
    // back to the paged-fetch version (bump `hasLoaded`/page tracking
    // instead of loading everything in one shot).
    private let sampleCount = 6
    @Published private(set) var isLoadingMore = false
    private var hasLoaded = false

    init() {
        loadNextPage()
    }

    var filteredAndSorted: [Letter] {
        var result = letters
        if let range = dateRange {
            result = result.filter { range.contains($0.date) }
        }
        switch sortOrder {
        case .newestFirst: result.sort { $0.date > $1.date }
        case .oldestFirst: result.sort { $0.date < $1.date }
        }
        return result
    }

    func loadNextPage() {
        guard !hasLoaded else { return }
        hasLoaded = true

        letters = (0..<sampleCount).map { i in
            Letter(
                title: Self.sampleTitles[i % Self.sampleTitles.count],
                date: Calendar.current.date(byAdding: .day, value: -i * 9, to: .now) ?? .now,
                content: Self.sampleContent[i % Self.sampleContent.count],
                emotion: Self.sampleEmotions[i % Self.sampleEmotions.count]
            )
        }
    }

    func delete(ids: Set<UUID>) {
        letters.removeAll { ids.contains($0.id) }
        selectedIDs.removeAll()
        isSelecting = false
    }

    func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    /// Creates a blank entry and returns it so the caller can open it
    /// through the same flow as tapping any real letter (see
    /// HomeView.handleCompose). Swap this for a real "create entry"
    /// call once there's persistence behind this.
    func createDraft() -> Letter {
        let draft = Letter(title: "", date: .now, content: "", emotion: "unwell")
        letters.insert(draft, at: 0)
        return draft
    }

    private static let sampleTitles = [
        "My bf so adorable", "Oreee cutee", "One more time",
        "Tetanggga gila", "Quiet day", "Write your first story"
    ]
    private static let sampleContent = [
        ""
    ]
    // Only "unwell" exists as a real asset so far — add the rest of the
    // mood set here as they land, and this'll pick them up automatically.
    private static let sampleEmotions = ["unwell"]
}
