//
//  HomeView.swift
//  Postbox
//
//  Created by Theona Arlinton on 10/08/26.
//

import SwiftUI

enum DiaryDisplayMode {
    case stack
    case grid
}

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = DiaryStore()
    
    @State private var showDateRangeSheet = false
    @State private var openedLetter: Letter?
    @State private var showJournalEditor = false
    @State private var displayMode: DiaryDisplayMode = .stack
    @State private var showDeleteConfirmation = false
    @State private var showFolderList = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                content
                    .safeAreaInset(edge: .top) {
                        topControls
                    }
                    .toolbar(.hidden, for: .navigationBar)
                    .sheet(isPresented: $showDateRangeSheet) {
                        DateRangeFilterSheet(
                            range: $store.dateRange,
                            journalDates: store.letters.map(\.date)
                        )
                    }
                    .navigationDestination(item: $openedLetter) { letter in
                        JournalDetailView()
                    }
                    .navigationDestination(isPresented: $showFolderList) {
                        FolderListView()
                    }
                
                // MARK: - Delete Confirmation Popup
                if showDeleteConfirmation {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showDeleteConfirmation = false
                            }
                        }
                        .zIndex(2000)
                    
                    deleteConfirmationPopup
                        .zIndex(2001)
                }
            }
        }
    }
    
    // MARK: - Delete Confirmation Popup
    private var deleteConfirmationPopup: some View {
        let count = store.selectedIDs.count
        let title = count == 1
            ? "Are you sure to delete this letter?"
            : "Are you sure to delete \(count) letters?"
        let message = "What you delete cannot be recovered."

        return VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)

                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)

            VStack(spacing: 12) {
                Button(action: {
                    withAnimation { showDeleteConfirmation = false }
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(12)
                }

                Button(action: {
                    store.delete(ids: store.selectedIDs)
                    store.isSelecting = false
                    store.selectedIDs.removeAll()
                    withAnimation { showDeleteConfirmation = false }
                }) {
                    Text("Delete")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(white: 0.95))
                        .cornerRadius(12)
                }
            }
        }
        .padding(32)          // ← now wraps title + buttons together
        .frame(width: 400)
        .background(
            Image("popup_bg")
                .resizable()
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
    }
    
    private var topControls: some View {
        VStack(spacing: 8) {
            ZStack {
                Text(store.isSelecting ? "\(store.selectedIDs.count) selected" : "My Diary")
                    .font(.title)

                HStack {
                if store.isSelecting {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            store.isSelecting = false
                            store.selectedIDs.removeAll()
                        }
                    } label: {
                        Image("button_silang")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 66, height: 66)
                    }
                } else {
                    Button {
                        showFolderList = true
                    } label: {
                        IconImage(name: "button_back")
                    }
                }

                Spacer()

                if store.isSelecting {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image("button_trash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 66, height: 66)
                    }
                    .disabled(store.selectedIDs.isEmpty)
                } else {
                    Button {
                        displayMode = (displayMode == .stack) ? .grid : .stack
                    } label: {
                        IconImage(name: displayMode == .stack ? "grid_amplop" : "stack_amplop")
                    }
                    
                    Button {
                        showDateRangeSheet = true
                    } label: {
                        IconImage(name: "button_calendar")
                    }
                    
                    Menu {
                        Button {
                            store.isSelecting = true
                        } label: {
                            Label("Select Letters", systemImage: "checkmark.circle")
                        }
                        
                        Divider()
                        
                        Picker("Sort By", selection: $store.sortOrder) {
                            Text("Newest First").tag(LetterSortOrder.newestFirst)
                            Text("Oldest First").tag(LetterSortOrder.oldestFirst)
                        }
                    } label: {
                        IconImage(name: "button_3dots")
                    }
                }
            }
            }

            if !store.isSelecting, let range = store.dateRange {
                dateRangeChip(range)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Date Range Chip

    private func dateRangeChip(_ range: ClosedRange<Date>) -> some View {
        HStack(spacing: 6) {
            Text(formattedDateRangeChip(range))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)

            Button {
                withAnimation {
                    store.dateRange = nil
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(white: 0.9))
        .clipShape(Capsule())
    }

    private func formattedDateRangeChip(_ range: ClosedRange<Date>) -> String {
        let calendar = Calendar.current
        let sameMonth = calendar.isDate(
            range.lowerBound,
            equalTo: range.upperBound,
            toGranularity: .month
        )

        let dayOnly = DateFormatter()
        dayOnly.dateFormat = "d"

        let dayAndMonth = DateFormatter()
        dayAndMonth.dateFormat = "d MMMM"

        if sameMonth {
            let start = dayOnly.string(from: range.lowerBound)
            let end = dayAndMonth.string(from: range.upperBound)
            return "\(start)–\(end)"
        } else {
            let start = dayAndMonth.string(from: range.lowerBound)
            let end = dayAndMonth.string(from: range.upperBound)
            return "\(start) – \(end)"
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch displayMode {
        case .stack:
            LetterStackView(
                letters: store.filteredAndSorted,
                isSelecting: store.isSelecting,
                selectedIDs: store.selectedIDs,
                onTapLetter: handleTap,
                onLongPressLetter: handleLongPress,
                onReachedBottom: store.loadNextPage
            )
        case .grid:
            LetterGridView(
                letters: store.filteredAndSorted,
                isSelecting: store.isSelecting,
                selectedIDs: store.selectedIDs,
                onTapLetter: handleTap
            )
        }
    }
    
    private func handleLongPress(_ letter: Letter) {
        if !store.isSelecting {
            store.isSelecting = true
        }
        store.toggleSelection(letter.id)
    }
    
    private func handleTap(_ letter: Letter) {
        if store.isSelecting {
            store.toggleSelection(letter.id)
        } else {
            openedLetter = letter
        }
    }
    
    private func handleCompose() {
        showJournalEditor = true
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            if !store.isSelecting {
                Button {
                    dismiss()
                } label: {
                    IconImage(name: "button_back")
                }
                
                Button {
                    displayMode = (displayMode == .stack) ? .grid : .stack
                } label: {
                    IconImage(name: displayMode == .stack ? "grid_amplop" : "stack_amplop", size: 30)
                }
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if store.isSelecting {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(store.selectedIDs.isEmpty)
                
                Button("Done") {
                    store.isSelecting = false
                    store.selectedIDs.removeAll()
                }
            } else {
                Button {
                    showDateRangeSheet = true
                } label: {
                    IconImage(name: "button_calendar")
                }
                
                Menu {
                    Button {
                        store.isSelecting = true
                    } label: {
                        Label("Select Letters", systemImage: "checkmark.circle")
                    }
                    
                    Divider()
                    
                    Picker("Sort By", selection: $store.sortOrder) {
                        Text("Newest First").tag(LetterSortOrder.newestFirst)
                        Text("Oldest First").tag(LetterSortOrder.oldestFirst)
                    }
                } label: {
                    IconImage(name: "button_3dots")
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
