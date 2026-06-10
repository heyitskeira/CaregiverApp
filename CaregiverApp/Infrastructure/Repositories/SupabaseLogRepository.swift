import Foundation
import UIKit
import Supabase

@MainActor
final class SupabaseLogRepository: LogRepository {
    private let careTeamID: UUID

    init(careTeamID: UUID) {
        self.careTeamID = careTeamID
    }

    func fetchLogs() async throws -> [Log] {
        struct LogWithContact: Codable {
            let id: UUID
            let careTeamID: UUID
            let authorContactID: UUID
            let content: String
            let imageURLs: [String]
            let createdAt: Date
            let contact: DBContactRow?

            enum CodingKeys: String, CodingKey {
                case id
                case careTeamID = "care_team_id"
                case authorContactID = "author_contact_id"
                case content
                case imageURLs = "image_urls"
                case createdAt = "created_at"
                case contact = "care_contacts"
            }
        }

        let rows: [LogWithContact] = try await supabase
            .from("care_logs")
            .select("*, care_contacts(*)")
            .eq("care_team_id", value: careTeamID)
            .order("created_at", ascending: false)
            .execute()
            .value

        return rows.map { row in
            let author = row.contact?.toDomain() ?? CareContact(
                id: row.authorContactID,
                careTeamID: row.careTeamID,
                name: "Unknown",
                relationship: ""
            )
            return Log(
                id: row.id,
                author: author,
                content: row.content,
                imageURLs: row.imageURLs,
                timestamp: row.createdAt
            )
        }
    }

    func saveLog(_ log: Log) async throws {
        var uploadedURLs: [String] = log.imageURLs

        // Upload any new in-memory images to Supabase Storage
        for image in log.images {
            guard let data = image.jpegData(compressionQuality: 0.85) else { continue }
            let path = "\(careTeamID)/\(log.id)/\(UUID().uuidString).jpg"
            try await supabase.storage
                .from(StorageBucket.logImages)
                .upload(path, data: data, options: FileOptions(contentType: "image/jpeg"))
            let publicURL = try supabase.storage
                .from(StorageBucket.logImages)
                .getPublicURL(path: path)
            uploadedURLs.append(publicURL.absoluteString)
        }

        let payload = LogPayload(
            id: log.id,
            careTeamID: careTeamID,
            authorContactID: log.author.id,
            content: log.content,
            imageURLs: uploadedURLs
        )
        try await supabase
            .from("care_logs")
            .upsert(payload)
            .execute()
    }

    func deleteLog(id: UUID) async throws {
        try await supabase
            .from("care_logs")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}

private struct LogPayload: Encodable {
    let id: UUID
    let careTeamID: UUID
    let authorContactID: UUID
    let content: String
    let imageURLs: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case careTeamID = "care_team_id"
        case authorContactID = "author_contact_id"
        case content
        case imageURLs = "image_urls"
    }
}
