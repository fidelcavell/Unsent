import SwiftUI

struct FolderListView: View {
    @StateObject private var viewModel = FolderListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Grid layout that adapts to screen size (great for iPad)
    let columns = [
        GridItem(.adaptive(minimum: 180), spacing: 24)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            // Dark overlay for selection mode
            Color.black
                .ignoresSafeArea()
                .opacity(viewModel.isSelectionModeActive ? 0.4 : 0)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isSelectionModeActive)
            
            VStack(spacing: 0) {
                customNavigationBar
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 32) {
                        ForEach(viewModel.folders) { folder in
                            FolderCardView(
                                folder: folder,
                                isSelectionModeActive: viewModel.isSelectionModeActive,
                                isSelected: viewModel.selectedFolderIds.contains(folder.id),
                                onOpen: {
                                    dismiss()
                                },
                                onSelect: {
                                    viewModel.toggleSelection(for: folder.id)
                                },
                                onEdit: {
                                    viewModel.openEditFolderModal(for: folder)
                                },
                                onDelete: {
                                    viewModel.confirmDelete(folder: folder)
                                }
                            )
                        }
                    }
                    .padding(40)
                }
            }
            
            // Centered modal overlay for New / Edit Folder
            if viewModel.isShowingNewFolderModal {
                // Dim background
                Color.black
                    .opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Menutup modal saat area luar di-tap (sama seperti cancel)
                        withAnimation {
                            viewModel.isShowingNewFolderModal = false
                        }
                    }
                    .transition(.opacity)
                
                // Centered card
                NewFolderModal(viewModel: viewModel)
                    .frame(maxWidth: 560, maxHeight: 560)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.18), radius: 32, x: 0, y: 12)
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
            
            // Delete Confirmation Popup
            if viewModel.isShowingDeleteModal {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                viewModel.isShowingDeleteModal = false
                            }
                        }
                    
                    deleteConfirmationPopup
                }
                .zIndex(10)
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isShowingNewFolderModal)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isShowingDeleteModal)
        .navigationBarHidden(true)
    }
    
    private var customNavigationBar: some View {
        ZStack {
            // Center title
            Text(viewModel.isSelectionModeActive ? "Manage My Letter" : "Letter Group")
                .font(.title)
                .fontWeight(.semibold)
            
            // Leading & Trailing buttons
            HStack {
                // LEFT: Cancel button (selection mode only)
                if viewModel.isSelectionModeActive {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.isSelectionModeActive = false
                        }
                    }) {
                        Image("button_silang")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    }
                }
                
                Spacer()
                
                // RIGHT: context-sensitive actions
                if viewModel.isSelectionModeActive {
                    HStack(spacing: 12) {
                        // Edit button — only when exactly 1 selected
                        if viewModel.selectedFolderIds.count == 1 {
                            Button(action: {
                                if let first = viewModel.selectedFolderIds.first,
                                   let folder = viewModel.folders.first(where: { $0.id == first }) {
                                    viewModel.openEditFolderModal(for: folder)
                                }
                            }) {
                                Image("button_edit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                            }
                        }
                        
                        // Delete button — when 1 or more selected
                        if !viewModel.selectedFolderIds.isEmpty {
                            Button(action: {
                                viewModel.confirmDeleteSelected()
                            }) {
                                Image("button_trash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                } else {
                    // Normal mode: Plus + Select
                    HStack(spacing: 16) {
                        Button(action: {
                            viewModel.openNewFolderModal()
                        }) {
                            Image("button_plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.isSelectionModeActive = true
                            }
                        }) {
                            Image("button_select")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .background(Color.clear)
    }
    
    // MARK: - Delete Confirmation Popup
    private var deleteConfirmationPopup: some View {
        let isMultiple = viewModel.folderToDelete == nil && !viewModel.selectedFolderIds.isEmpty
        let title = isMultiple ? "Are you sure to delete selected folders?" : "Are you sure to delete this folder?"
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
                    withAnimation {
                        viewModel.isShowingDeleteModal = false
                    }
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
                    withAnimation {
                        if let folderId = viewModel.folderToDelete?.id {
                            viewModel.deleteFolder(folderId: folderId)
                        } else if !viewModel.selectedFolderIds.isEmpty {
                            viewModel.deleteSelectedFolders()
                        }
                    }
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
        .padding(32)
        .frame(width: 400)
        .background(
            Image("popup_bg")
                .resizable()
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
    }
}

#Preview {
    FolderListView()
}
