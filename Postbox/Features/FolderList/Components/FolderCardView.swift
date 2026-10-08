import SwiftUI

struct FolderCardView: View {
    let folder: FolderItem
    let isSelectionModeActive: Bool
    let isSelected: Bool
    let onOpen: () -> Void
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Folder Asset View
            Image(folder.assetPath)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            // Label Pill
            HStack(spacing: 6) {
                if isSelectionModeActive {
                    // Native SF Symbol checklist icon
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .accentColor : Color(UIColor.systemGray3))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                }
                Text("\(folder.name) (\(folder.viewCount))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6))
            .clipShape(Capsule())
        }
        // Highlight selected item, dim unselected items in selection mode
        .opacity(isSelectionModeActive && !isSelected ? 0.45 : 1.0)
        .scaleEffect(isSelectionModeActive && isSelected ? 1.04 : (isPressed ? 0.94 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        .contentShape(.interaction, Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in
                    isPressed = false
                    if isSelectionModeActive {
                        onSelect()
                    } else {
                        onOpen()
                    }
                }
        )
        // Context menu only active outside selection mode
        .contextMenuIfNeeded(enabled: !isSelectionModeActive) {
            Button(action: onEdit) {
                Label("Edit Folder", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete Folder", systemImage: "trash")
            }
        }
    }
}

// MARK: - Conditional Context Menu Helper
private extension View {
    @ViewBuilder
    func contextMenuIfNeeded<MenuItems: View>(
        enabled: Bool,
        @ViewBuilder menuItems: () -> MenuItems
    ) -> some View {
        if enabled {
            self.contextMenu(menuItems: menuItems)
        } else {
            self
        }
    }
}
