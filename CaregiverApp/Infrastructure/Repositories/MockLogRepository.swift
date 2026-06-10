import Foundation

@MainActor
final class MockLogRepository: LogRepository {
    private var logs: [Log] = []

    func fetchLogs() async throws -> [Log] {
        logs
    }

    func saveLog(_ log: Log) async throws {
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs[index] = log
        } else {
            logs.insert(log, at: 0)
        }
    }

    func deleteLog(id: UUID) async throws {
        logs.removeAll { $0.id == id }
    }
}
