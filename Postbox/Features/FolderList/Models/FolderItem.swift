import Foundation

enum FolderViewType: String, CaseIterable, Identifiable {
    case mailBox = "MailBox"
    case mailStack = "MailStack"
    
    var id: String { self.rawValue }
    
    var assetPath: String {
        switch self {
        case .mailBox:
            return "MailBox"
        case .mailStack:
            return "MailStack"
        }
    }
}

struct FolderItem: Identifiable, Hashable {
    let id: UUID
    var name: String
    var viewCount: Int
    var viewType: FolderViewType
    
    var assetPath: String {
        return viewType.assetPath
    }
}
