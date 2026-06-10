import Foundation

protocol LogRepository: Sendable {
    func fetchLogs() async throws -> [Log]
    func saveLog(_ log: Log) async throws
    func deleteLog(id: UUID) async throws
}
