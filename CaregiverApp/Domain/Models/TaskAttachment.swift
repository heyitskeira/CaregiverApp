import Foundation

struct TaskAttachment: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var fileName: String
    var fileType: AttachmentType
    var localURL: URL? // before
    var remoteURL: URL? // aftrer
    var imageData: Data?

    var displayName: String {
        fileName.isEmpty ? "Untitled" : fileName
    }

    var iconName: String {
        switch fileType {
        case .image:
            return "photo"
        case .pdf:
            return "doc.richtext"
        case .document:
            return "doc.text"
        case .other:
            return "paperclip"
        }
    }

    init(
        id: UUID = UUID(),
        fileName: String,
        fileType: AttachmentType = .other,
        localURL: URL? = nil,
        remoteURL: URL? = nil,
        imageData: Data? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.localURL = localURL
        self.remoteURL = remoteURL
        self.imageData = imageData
    }
}

enum AttachmentType: String, Hashable, Codable {
    case image
    case pdf
    case document
    case other

    static func from(mimeType: String) -> AttachmentType {
        if mimeType.hasPrefix("image/") { return .image }
        if mimeType == "application/pdf" { return .pdf }
        if mimeType.hasPrefix("text/") || mimeType.contains("document") { return .document }
        return .other
    }

    static func from(fileExtension: String) -> AttachmentType {
        let ext = fileExtension.lowercased()
        switch ext {
        case "jpg", "jpeg", "png", "heic", "gif", "webp":
            return .image
        case "pdf":
            return .pdf
        case "doc", "docx", "txt", "rtf", "pages":
            return .document
        default:
            return .other
        }
    }
}
