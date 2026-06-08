import SwiftUI

struct InboxView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var tasks: [CareTask] = [
        CareTask(
            title: "Poopie Pants",
            scheduledAt: .now,
            durationMinutes: 120,
            careTeamID: UUID(),
            patientID: UUID(),
            createdByID: UUID()
        ),
        CareTask(
            title: "Puke Nuke",
            scheduledAt: .now.addingTimeInterval(3600),
            durationMinutes: 30,
            careTeamID: UUID(),
            patientID: UUID(),
            createdByID: UUID()
        )
    ]
    
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

                Text("\(tasks.count) task request\(tasks.count == 1 ? "" : "s")")
                    .fontWeight(.semibold)

                Spacer()

                Button("Accept All") {

                    for task in tasks {
                        print("Accepted \(task.title)")
                    }

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

            ScrollView {

                VStack(alignment: .leading, spacing: 16) {

                    Text(displayDate)
                        .font(.body)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)

                    ForEach(tasks) { task in

                        InboxRow(
                            task: task,
                            onAccept: {

                                print("Accepted \(task.title)")

                            },
                            onDecline: {

                                print("Declined \(task.title)")

                            }
                        )
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct InboxRow: View {

    let task: CareTask

    let onAccept: () -> Void
    let onDecline: () -> Void

    private var timeText: String {

        let endTime = task.scheduledAt.addingTimeInterval(
            Double(task.durationMinutes * 60)
        )

        return "\(task.scheduledAt.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))"
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

                HStack(spacing: 6) {

                    Button {
                        onDecline()
                    } label: {
                        Text("Decline")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(width: 65)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .foregroundStyle(.tint)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                        .stroke(.tint, lineWidth: 2)
                    )

                    Button {
                        onAccept()
                    } label: {
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .frame(width: 65)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(.accent)
                    .clipShape(Capsule())
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
}
