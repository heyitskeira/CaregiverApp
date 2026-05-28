import SwiftUI

struct TimelineView: View {
    @State private var selectedTab = 0
    
    let allTasks: [TimelineTaskModel] = [
        TimelineTaskModel(startTime: "05.00", endTime: "05.30", duration: "30 min", title: "Prep", initials: "AA", isCompleted: true, hasRepeatIcon: true, color: .red.opacity(0.9), iconSystemName: nil),
        TimelineTaskModel(startTime: "06.00", endTime: "06.15", duration: "15 min", title: "Change", initials: "AA", isCompleted: true, hasRepeatIcon: true, color: .green.opacity(0.7), iconSystemName: nil),
        TimelineTaskModel(startTime: "06.15", endTime: "06.30", duration: "15 min", title: "Give Meds", initials: "AA", isCompleted: true, hasRepeatIcon: true, color: .green.opacity(0.7), iconSystemName: nil),
        TimelineTaskModel(startTime: "06.30", endTime: "07.30", duration: "1 hr", title: "Give Bfast", initials: "SA", isCompleted: true, hasRepeatIcon: true, color: .green.opacity(0.7), iconSystemName: nil),
        TimelineTaskModel(startTime: "09.00", endTime: "10.00", duration: "1 hr", title: "Give Bath", initials: "SA", isCompleted: false, hasRepeatIcon: true, color: .gray.opacity(0.7), iconSystemName: nil),
        TimelineTaskModel(startTime: "13.00", endTime: "15.00", duration: "2 hr", title: "Hospital Visit", initials: nil, isCompleted: false, hasRepeatIcon: false, color: .gray.opacity(0.7), iconSystemName: "person.badge.plus")
    ]
    
    let myTasks: [TimelineTaskModel] = [
        TimelineTaskModel(startTime: "13.00", endTime: "15.00", duration: "2 hr", title: "Hospital Visit..", initials: "AA", isCompleted: false, hasRepeatIcon: false, color: .gray, iconSystemName: nil, isPending: true, showDocumentIcon: false),
        TimelineTaskModel(startTime: "17.00", endTime: "17.30", duration: "30 min", title: "Prepare Dinner", initials: "AA", isCompleted: false, hasRepeatIcon: true, color: .orange.opacity(0.7), iconSystemName: nil, isPending: false, showDocumentIcon: true),
        TimelineTaskModel(startTime: "19.00", endTime: "20.00", duration: "30 min", title: "Give Meds", initials: "AA", isCompleted: false, hasRepeatIcon: false, color: .gray, iconSystemName: nil, isPending: true, showDocumentIcon: true)
    ]
    
    var activeTasks: [TimelineTaskModel] {
        selectedTab == 0 ? allTasks : myTasks
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
            
            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        ForEach(activeTasks.indices, id: \.self) { index in
                            TimelineTaskRow(
                                task: activeTasks[index],
                                isLast: index == activeTasks.count - 1
                            )
                            .padding(.bottom, index == activeTasks.count - 1 ? 120 : 0)
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
        TimelineView()
    }
}
