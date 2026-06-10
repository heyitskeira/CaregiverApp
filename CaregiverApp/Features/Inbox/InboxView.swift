import SwiftUI

struct InboxItem: Identifiable {
    let id: UUID
    let requestID: UUID
    let taskTitle: String
    let scheduledAt: Date
    let durationMinutes: Int
    let requesterName: String
    let requesterInitials: String
}

@Observable
@MainActor
final class InboxStore {
    private(set) var items: [InboxItem] = []
    private(set) var isLoading = false
    var errorMessage: String?

    func load(
        taskRequestRepository: any TaskRequestRepository,
        taskRepository: any TaskRepository,
        contactRepository: any ContactRepository
    ) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            let requests = try await taskRequestRepository.fetchPendingRequests()
            let tasks = try await taskRepository.fetchAllTasks()
            let contacts = try await contactRepository.fetchContacts()
            let tasksByID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
            let contactsByID = Dictionary(uniqueKeysWithValues: contacts.map { ($0.id, $0) })
            items = requests.compactMap { request -> InboxItem? in
                guard let task = tasksByID[request.taskID],
                      let requester = contactsByID[request.requesterID] else { return nil }
                return InboxItem(
                    id: request.id,
                    requestID: request.id,
                    taskTitle: task.title,
                    scheduledAt: task.scheduledAt,
                    durationMinutes: task.durationMinutes,
                    requesterName: requester.name,
                    requesterInitials: requester.initials
                )
            }
        } catch {
            errorMessage = "Could not load inbox."
        }
    }

    func accept(
        _ item: InboxItem,
        taskRequestRepository: any TaskRequestRepository
    ) async {
        do {
            try await taskRequestRepository.accept(item.requestID)
            items.removeAll { $0.id == item.id }
        } catch {
            errorMessage = "Could not accept request."
        }
    }

    func decline(
        _ item: InboxItem,
        taskRequestRepository: any TaskRequestRepository
    ) async {
        do {
            try await taskRequestRepository.decline(item.requestID)
            items.removeAll { $0.id == item.id }
        } catch {
            errorMessage = "Could not decline request."
        }
    }

    func acceptAll(taskRequestRepository: any TaskRequestRepository) async {
        do {
            try await taskRequestRepository.acceptAll()
            items.removeAll()
        } catch {
            errorMessage = "Could not accept all requests."
        }
    }
}

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.taskRequestRepository) private var taskRequestRepository
    @Environment(\.taskRepository) private var taskRepository
    @Environment(\.contactRepository) private var contactRepository

    @State private var store = InboxStore()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3).padding()
                        .background(Color.white).clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                Spacer()
            }
            .padding(.horizontal).padding(.top, 10)

            HStack {
                Text("Inbox").font(.largeTitle).fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal).padding(.top, 10)

            Divider().padding(.vertical, 10)

            if store.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if store.items.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No Task Requests",
                    systemImage: "tray",
                    description: Text("When care group members volunteer for tasks, they'll appear here.")
                )
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "hand.wave.fill")
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.orange.opacity(0.8))
                                .clipShape(Circle())

                            Text("\(store.items.count) task request\(store.items.count == 1 ? "" : "s")")
                                .font(.headline).fontWeight(.bold)

                            Spacer()

                            Button("Accept All") {
                                Task { await store.acceptAll(taskRequestRepository: taskRequestRepository) }
                            }
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal).padding(.bottom, 8)

                        ForEach(store.items) { item in
                            InboxRow(
                                item: item,
                                onAccept: {
                                    Task { await store.accept(item, taskRequestRepository: taskRequestRepository) }
                                },
                                onDecline: {
                                    Task { await store.decline(item, taskRequestRepository: taskRequestRepository) }
                                }
                            )
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await store.load(
                taskRequestRepository: taskRequestRepository,
                taskRepository: taskRepository,
                contactRepository: contactRepository
            )
        }
        .refreshable {
            await store.load(
                taskRequestRepository: taskRequestRepository,
                taskRepository: taskRepository,
                contactRepository: contactRepository
            )
        }
        .alert("Error", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.errorMessage ?? "")
        }
    }
}

struct InboxRow: View {
    let item: InboxItem
    var onAccept: () -> Void
    var onDecline: () -> Void

    private var timeRange: String {
        let start = item.scheduledAt.formatted(.dateTime.hour().minute())
        let end = Calendar.current.date(byAdding: .minute, value: item.durationMinutes, to: item.scheduledAt)!
            .formatted(.dateTime.hour().minute())
        let hours = item.durationMinutes / 60
        let mins = item.durationMinutes % 60
        let durationStr = hours > 0
            ? "\(hours)h\(mins > 0 ? " \(mins)m" : "")"
            : "\(mins)m"
        return "\(start)–\(end) (\(durationStr))"
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle().fill(Color.accentColor.opacity(0.15)).frame(width: 50, height: 50)
                    Text(item.requesterInitials)
                        .font(.headline.bold())
                        .foregroundColor(.accentColor)
                }
                Image(systemName: "hand.raised.fill")
                    .font(.caption2).foregroundColor(.white)
                    .padding(4)
                    .background(Color.orange.opacity(0.8))
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.taskTitle).font(.headline).fontWeight(.semibold)
                Text(item.scheduledAt.formatted(.dateTime.day().month(.wide).year()))
                    .font(.subheadline)
                HStack(spacing: 4) {
                    Image(systemName: "clock").foregroundColor(.orange.opacity(0.8))
                    Text(timeRange).foregroundColor(.gray)
                }
                .font(.caption)
                Text("Requested by \(item.requesterName)")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: onAccept) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2).foregroundColor(.green)
                }
                Button(action: onDecline) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2).foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)

        Divider().padding(.leading, 70)
    }
}

#Preview {
    InboxView()
        .environment(\.taskRequestRepository, AppDependencies.live.taskRequestRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
}
