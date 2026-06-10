import Foundation

@MainActor
final class MockTaskRequestRepository: TaskRequestRepository {
    private var requests: [TaskRequest] = SeedData.sampleTaskRequests

    func fetchPendingRequests() async throws -> [TaskRequest] {
        requests.filter { $0.status == .pending }
    }

    func accept(_ requestID: UUID) async throws {
        guard let index = requests.firstIndex(where: { $0.id == requestID }) else { return }
        requests[index].status = .accepted
    }

    func decline(_ requestID: UUID) async throws {
        guard let index = requests.firstIndex(where: { $0.id == requestID }) else { return }
        requests[index].status = .declined
    }

    func acceptAll() async throws {
        for index in requests.indices where requests[index].status == .pending {
            requests[index].status = .accepted
        }
    }
}
