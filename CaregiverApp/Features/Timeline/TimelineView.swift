import SwiftUI

struct TimelineView: View {
    @Environment(\.taskRepository) private var taskRepository
    @Environment(\.contactRepository) private var contactRepository

    let reloadToken: UUID

    @State private var store: TimelineStore?
    @State private var selectedTab = 0

    private var activeTasks: [TimelineTaskModel] {
        guard let store else { return [] }
        return selectedTab == 0 ? store.allTasks : store.myTasks
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Text("26 May")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("2026")
                        .font(.title2)
                        .foregroundStyle(.gray)
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()

                NavigationLink(destination: InboxView()) {
                    Image(systemName: "tray.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .fill(.red)
                                .frame(width: 12, height: 12)
                                .offset(x: 0, y: 0)
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            HStack {
                let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                let dates = [24, 25, 26, 27, 28, 29, 30]

                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 8) {
                        Text(days[i])
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray.opacity(0.8))

                        Text("\(dates[i])")
                            .font(.headline)
                            .fontWeight(dates[i] == 26 ? .bold : .semibold)
                            .foregroundStyle(dates[i] == 26 ? .blue : .primary)
                            .frame(width: 36, height: 36)
                            .background {
                                if dates[i] == 26 {
                                    Circle().fill(Color.blue.opacity(0.1))
                                }
                            }
                    }
                    if i < 6 { Spacer() }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Divider().padding(.vertical, 16)

            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    Text("All Task")
                        .font(.subheadline)
                        .fontWeight(selectedTab == 0 ? .semibold : .regular)
                        .foregroundColor(selectedTab == 0 ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selectedTab == 0 {
                                Capsule().fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                            }
                        }
                }

                Button(action: { selectedTab = 1 }) {
                    Text("My Task")
                        .font(.subheadline)
                        .fontWeight(selectedTab == 1 ? .semibold : .regular)
                        .foregroundColor(selectedTab == 1 ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selectedTab == 1 {
                                Capsule().fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                            }
                        }
                }
            }
            .padding(4)
            .background(Color.gray.opacity(0.15))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            Group {
                if store?.isLoading == true, activeTasks.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if activeTasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "calendar",
                        description: Text(
                            selectedTab == 0
                                ? "Create a task with the + button."
                                : "No tasks assigned to you yet."
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        ZStack(alignment: .topLeading) {
                            VStack(spacing: 0) {
                                ForEach(activeTasks) { task in
                                    TimelineTaskRow(
                                        task: task,
                                        isLast: task.id == activeTasks.last?.id
                                    )
                                    .padding(.bottom, task.id == activeTasks.last?.id ? 120 : 0)
                                }
                            }
                            .padding(.horizontal)

                            if selectedTab == 0 {
                                CurrentTimeIndicator()
                                    .padding(.top, 340)
                            }
                        }
                    }
                }
            }
        }
        .task(id: reloadToken) {
            await reloadTasks()
        }
        .refreshable {
            await store?.load()
        }
    }

    private func reloadTasks() async {
        if store == nil {
            store = TimelineStore(
                taskRepository: taskRepository,
                contactRepository: contactRepository
            )
        }
        await store?.load()
    }
}

struct CurrentTimeIndicator: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("09:41")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red)
                .clipShape(Capsule())
                .padding(.leading, 8)

            Rectangle()
                .fill(Color.red)
                .frame(height: 1.5)
                .padding(.trailing, 24)
        }
    }
}

#Preview {
    NavigationStack {
        TimelineView(reloadToken: UUID())
    }
    .environment(\.taskRepository, AppDependencies.live.taskRepository)
    .environment(\.contactRepository, AppDependencies.live.contactRepository)
}
