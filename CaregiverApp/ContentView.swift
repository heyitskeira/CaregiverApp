//
//  ContentView.swift
//  CaregiverApp
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case timeline
    case details
    case settings

    var title: String {
        switch self {
        case .timeline:
            return "Timeline"
        case .details:
            return "Details"
        case .settings:
            return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .timeline:
            return "list.bullet.rectangle.portrait"
        case .details:
            return "stethoscope" // Changed to match stethoscope from image
        case .settings:
            return "gearshape"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .timeline
    @State private var showTaskSheet = false
    @State private var timelineReloadToken = UUID()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .timeline:
                    NavigationStack {
                        TimelineView(reloadToken: timelineReloadToken)
                    }
                case .details:
                    NavigationStack {
                        PatientDetailsTabView()
                    }
                case .settings:
                    NavigationStack {
                        SettingsRootView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack(spacing: 16) {
                HStack(spacing: 0) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.title2)
                                    .fontWeight(selectedTab == tab ? .bold : .regular)
                                Text(tab.title)
                                    .font(.caption2)
                                    .fontWeight(selectedTab == tab ? .bold : .semibold)
                            }
                            .foregroundColor(selectedTab == tab ? Color(red: 0.2, green: 0.4, blue: 0.8) : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                if selectedTab == tab {
                                    Color.gray.opacity(0.15)
                                        .clipShape(Capsule())
                                        .padding(.horizontal, 4)
                                }
                            }
                        }
                    }
                }
                .frame(height: 70)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Button(action: {
                    showTaskSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .frame(width: 70, height: 70)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showTaskSheet, onDismiss: {
            timelineReloadToken = UUID()
        }) {
            TaskSheetView()
        }
    }
}

#Preview {
    ContentView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
