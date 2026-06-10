import Foundation

protocol TaskRequestRepository: Sendable {
    func fetchPendingRequests() async throws -> [TaskRequest]
    func accept(_ requestID: UUID) async throws
    func decline(_ requestID: UUID) async throws
    func acceptAll() async throws
}
