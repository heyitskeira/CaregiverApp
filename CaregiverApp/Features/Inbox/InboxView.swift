import SwiftUI

struct InboxView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.taskRepository) private var taskRepository

    @State private var requests: [TaskRequest] = []
    @State private var tasksByID: [UUID: CareTask] = [:]
    @State private var isLoading = true

    private var displayDate: String {
        if Calendar.current.isDateInToday(Date()) {
            return "Today"
        }
        return Date().formatted(
            .dateTime
                .day()
                .month(.wide)
                .year()
        )
    }

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(
                            color: .black.opacity(0.05),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)

            HStack {
                Text("Inbox")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            HStack {
                Text("\(requests.count) task request\(requests.count == 1 ? "" : "s")")
                    .fontWeight(.semibold)

                Spacer()

                Button("Accept All") {
                    acceptAll()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 36)
                .padding(.vertical, 8)
                .foregroundStyle(.tint)
                .background(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .stroke(.tint, lineWidth: 2)
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 14)

            Divider()
                .padding(.bottom, 14)

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if requests.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.4))
                    Text("No pending requests")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(displayDate)
                            .font(.body)
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)

                        ForEach(requests) { request in
                            if let task = tasksByID[request.taskID] {
                                InboxRow(
                                    task: task,
                                    onAccept: {
                                        acceptRequest(request)
                                    },
                                    onDecline: {
                                        declineRequest(request)
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await loadRequests()
        }
    }

    private func loadRequests() async {
        isLoading = true
        defer { isLoading = false }

        do {
            requests = try await taskRepository.fetchAllPendingRequests()
            let allTasks = try await taskRepository.fetchAllTasks()
            tasksByID = Dictionary(uniqueKeysWithValues: allTasks.map { ($0.id, $0) })
        } catch {
            requests = []
        }
    }

    private func acceptRequest(_ request: TaskRequest) {
        Task {
            try? await taskRepository.updateRequestStatus(id: request.id, status: .accepted)
            // Add an assignment for the requester
            let assignment = TaskAssignment(
                taskID: request.taskID,
                assigneeID: request.requesterID,
                assignedByID: request.requesterID
            )
            try? await taskRepository.addAssignment(assignment)
            // Update task status to assigned
            if var task = tasksByID[request.taskID] {
                task.status = .assigned
                try? await taskRepository.updateTask(task)
            }
            // Remove from local list
            withAnimation {
                requests.removeAll { $0.id == request.id }
            }
        }
    }

    private func declineRequest(_ request: TaskRequest) {
        Task {
            try? await taskRepository.updateRequestStatus(id: request.id, status: .declined)
            withAnimation {
                requests.removeAll { $0.id == request.id }
            }
        }
    }

    private func acceptAll() {
        for request in requests {
            acceptRequest(request)
        }
    }
}

struct InboxRow: View {

    let task: CareTask

    let onAccept: () -> Void
    let onDecline: () -> Void

    private var endTime: Date {
        task.scheduledAt.addingTimeInterval(Double(task.durationMinutes * 60))
    }

    private var timeText: String {
        "\(task.scheduledAt.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))"
    }

    private var durationText: String {
        if task.durationMinutes >= 60 {
            let hours = Double(task.durationMinutes) / 60
            return "\(hours.formatted()) hr"
        }
        return "\(task.durationMinutes) min"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "hand.wave")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.orange.opacity(0.65))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("\(timeText) (\(durationText))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    // Gray X (decline)
                    Button(action: onDecline) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                            )
                    }

                    // Blue checkmark (accept)
                    Button(action: onAccept) {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.medium))
                            .foregroundColor(Color(hex: 0x2051B9))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: 0x2051B9), lineWidth: 1.5)
                            )
                    }
                }
            }
            .padding(.horizontal)

            Divider()
                .padding(.leading, 70)
        }
    }
}

#Preview {
    InboxView()
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
}
