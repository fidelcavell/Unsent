import SwiftUI

struct NewFolderModal: View {
    @ObservedObject var viewModel: FolderListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                // Cancel Button (X)
                Button(action: {
                    viewModel.isShowingNewFolderModal = false
                }) {
                    Image("button_silang")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                // Title
                Text(viewModel.editingFolderId == nil ? "New Folder" : "Edit Folder")
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
                
                // Confirm Button (Checkmark)
                Button(action: {
                    guard !viewModel.draftFolderName.isEmpty else { return }
                    viewModel.onCreateFolderSubmitted()
                }) {
                    Image("button_checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                .opacity(viewModel.draftFolderName.isEmpty ? 0.4 : 1.0)
                .disabled(viewModel.draftFolderName.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 32) {
                // Folder Name Input Pill
                HStack {
                    TextField("Folder Name", text: $viewModel.draftFolderName)
                        .font(.system(size: 16))
                    
                    if !viewModel.draftFolderName.isEmpty {
                        Button(action: {
                            viewModel.draftFolderName = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemGray6))
                .clipShape(Capsule())
                .padding(.top, 40)
                
                // Folder View Selection Area
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose Your Folder View.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 24) {
                        FolderViewSelectionCard(
                            viewType: .mailBox,
                            isSelected: viewModel.draftFolderViewType == .mailBox,
                            action: { viewModel.draftFolderViewType = .mailBox }
                        )
                        
                        FolderViewSelectionCard(
                            viewType: .mailStack,
                            isSelected: viewModel.draftFolderViewType == .mailStack,
                            action: { viewModel.draftFolderViewType = .mailStack }
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// Subcomponent for view selection image cards
struct FolderViewSelectionCard: View {
    let viewType: FolderViewType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                    )
                
                Image(viewType.assetPath)
                    .resizable()
                    .scaledToFit()
                    .padding(32)
            }
            .frame(height: 180)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
