import UIKit

struct Log: Identifiable {
    let id: UUID
    let author: CareContact
    var content: String
    /// Remote Storage URLs — persisted to Supabase.
    var imageURLs: [String]
    /// In-memory UIImages — populated after fetching from Storage, never saved directly.
    var images: [UIImage]
    var timestamp: Date

    init(
        id: UUID = UUID(),
        author: CareContact,
        content: String,
        imageURLs: [String] = [],
        images: [UIImage] = [],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.author = author
        self.content = content
        self.imageURLs = imageURLs
        self.images = images
        self.timestamp = timestamp
    }
}

// MARK: - Supabase DB row (Codable)

struct LogRow: Codable {
    let id: UUID
    let careTeamID: UUID
    let authorContactID: UUID
    let content: String
    let imageURLs: [String]
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case careTeamID = "care_team_id"
        case authorContactID = "author_contact_id"
        case content
        case imageURLs = "image_urls"
        case createdAt = "created_at"
    }
}
