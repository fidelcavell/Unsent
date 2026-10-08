import Foundation
internal import Combine

class FolderListViewModel: ObservableObject {
    // Current list of folders
    @Published var folders: [FolderItem] = []
    
    // View state
    @Published var isShowingNewFolderModal: Bool = false
    @Published var isShowingDeleteModal: Bool = false
    @Published var isSelectionModeActive: Bool = false {
        didSet {
            if !isSelectionModeActive {
                clearSelection()
            }
        }
    }
    
    // Selection state
    @Published var selectedFolderIds: Set<UUID> = []
    
    // Draft state for create/edit
    @Published var editingFolderId: UUID? = nil
    @Published var draftFolderName: String = ""
    @Published var draftFolderViewType: FolderViewType = .mailBox
    
    // State for deletion
    @Published var folderToDelete: FolderItem? = nil
    
    init() {
        // Mock data to replicate design
        folders = [
            FolderItem(id: UUID(), name: "My Diary", viewCount: 6, viewType: .mailBox),
            FolderItem(id: UUID(), name: "About You", viewCount: 1, viewType: .mailStack)
        ]
    }
    
    // MARK: - Navigation / Modals
    
    func openNewFolderModal() {
        draftFolderName = ""
        draftFolderViewType = .mailBox
        editingFolderId = nil
        isShowingNewFolderModal = true
    }
    
    func openEditFolderModal(for folder: FolderItem) {
        draftFolderName = folder.name
        draftFolderViewType = folder.viewType
        editingFolderId = folder.id
        isShowingNewFolderModal = true
    }
    
    func confirmDelete(folder: FolderItem) {
        folderToDelete = folder
        isShowingDeleteModal = true
    }
    
    func confirmDeleteSelected() {
        folderToDelete = nil
        isShowingDeleteModal = true
    }
    
    // MARK: - Actions
    
    func toggleSelection(for folderId: UUID) {
        if selectedFolderIds.contains(folderId) {
            selectedFolderIds.remove(folderId)
        } else {
            selectedFolderIds.insert(folderId)
        }
    }
    
    func clearSelection() {
        selectedFolderIds.removeAll()
    }
    
    func createNewFolder(name: String, viewType: FolderViewType) {
        let newFolder = FolderItem(id: UUID(), name: name, viewCount: 0, viewType: viewType)
        folders.append(newFolder)
        isShowingNewFolderModal = false
    }
    
    func updateFolder(folderId: UUID, newName: String, newViewType: FolderViewType) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            folders[index].name = newName
            folders[index].viewType = newViewType
        }
        isShowingNewFolderModal = false
    }
    
    func deleteFolder(folderId: UUID) {
        folders.removeAll { $0.id == folderId }
        isShowingDeleteModal = false
        folderToDelete = nil
    }
    
    func deleteSelectedFolders() {
        folders.removeAll { selectedFolderIds.contains($0.id) }
        clearSelection()
        isSelectionModeActive = false
        isShowingDeleteModal = false
    }
    
    func onCreateFolderSubmitted() {
        if let id = editingFolderId {
            updateFolder(folderId: id, newName: draftFolderName, newViewType: draftFolderViewType)
        } else {
            createNewFolder(name: draftFolderName, viewType: draftFolderViewType)
        }
    }
    
    func onFolderOpened(folderId: UUID) {
        print("Navigation Request: Open folder with ID \(folderId)")
    }
}
