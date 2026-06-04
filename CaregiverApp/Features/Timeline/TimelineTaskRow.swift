import SwiftUI

struct TimelineTaskModel: Identifiable {
    let id: UUID
    let startTime: String
    let endTime: String
    let duration: String
    let title: String
    let initials: String?
    let isCompleted: Bool
    let hasRepeatIcon: Bool
    let color: Color
    let iconSystemName: String?
    var isPending: Bool = false
    var showDocumentIcon: Bool = false
}

struct TimelineTaskRow: View {
    let task: TimelineTaskModel
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(task.startTime)
                .font(.subheadline)
                .foregroundStyle(.gray)
                .frame(width: 45, alignment: .trailing)
                .padding(.top, 10)
            
            VStack(spacing: 0) {
                Group {
                    if let initials = task.initials {
                        if task.isPending {
                            Text(initials)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(width: 50, height: 80)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                                        .foregroundColor(.gray)
                                )
                        } else {
                            Text(initials)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 50, height: task.isCompleted ? 50 : 80)
                                .background(task.color)
                                .clipShape(Capsule())
                        }
                    } else if let icon = task.iconSystemName {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 70)
                            .background(task.color)
                            .clipShape(Capsule())
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                                .foregroundColor(task.color)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(task.startTime)-\(task.endTime) (\(task.duration))")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    if task.hasRepeatIcon {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
                
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(task.isCompleted ? .gray : .primary)
                    .strikethrough(task.isCompleted)
                
                if task.showDocumentIcon {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 10)
            
            Spacer()
            
            if task.isPending {
                HStack(spacing: 8) {
                    Button("Accept") {
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                    .clipShape(Capsule())
                    
                    Button("Decline") {
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
                }
                .padding(.top, 10)
            } else {
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                        .padding(.top, 10)
                } else {
                    Circle()
                        .stroke(Color(red: 0.1, green: 0.2, blue: 0.4), lineWidth: 3)
                        .frame(width: 22, height: 22)
                        .padding(.top, 10)
                }
            }
        }
    }
}
