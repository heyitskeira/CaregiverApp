//
//  MainLogView.swift
//  CaregiverApp
//

import SwiftUI

struct MainLogView: View {
    @Environment(\.logRepository) private var logRepository
    @Environment(\.authService) private var authService

    @State private var showingAddLog = false
    @State private var logs: [Log] = []
    @State private var isLoading = false

    var body: some View {
        Group {

            if isLoading && logs.isEmpty {

                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {

                if logs.isEmpty {

                    composeButton
                        .padding(.horizontal)

                    Spacer()

                    VStack(spacing: 10) {

                        Image(systemName: "square.and.pencil")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                            .opacity(0.4)

                        VStack(spacing: 7) {

                            Text("No activity yet")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                                .opacity(0.5)

                            Text("Updates from the care team will appear here — or add the first one yourself.")
                                .frame(width: 280)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()

                    Spacer()
                    Spacer()

                } else {

                    ScrollView {

                        LazyVStack(spacing: 0) {

                            composeButton
                                .padding(.horizontal)
                                .padding(.vertical, 8)

                            Divider()

                            ForEach(logs) { log in

                                LogPost(
                                    log: log,
                                    onDelete: {
                                        logs.removeAll { $0.id == log.id }
                                    }
                                )

                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .refreshable {
                        await reloadLogs()
                    }
                }
            }
        }
        .navigationTitle("Log")
        .sheet(isPresented: $showingAddLog) {

            AddLogSheetView { newLog in

                Task {

                    try? await logRepository.saveLog(newLog)
                    await reloadLogs()
                }
            }
        }
        .task {
            await reloadLogs()
        }
    }

    private var composeButton: some View {

        Button {
            showingAddLog = true

        } label: {

            HStack {

                Image(systemName: "person.crop.circle.fill")
                    .font(.largeTitle)

                VStack(alignment: .leading) {

                    Text(authService.currentUser?.name ?? "Caregiver")
                        .font(.body)
                        .fontWeight(.semibold)

                    Text("Anything to let others know?")
                        .font(.subheadline)
                        .opacity(0.5)
                }

                Spacer()

                Image(systemName: "square.and.pencil")
                    .font(.title)
            }
        }
        .buttonStyle(.glass)
        .padding(.vertical, 8)
    }

    private func reloadLogs() async {

        isLoading = true
        defer { isLoading = false }

        logs = (try? await logRepository.fetchLogs()) ?? []
    }
}

#Preview {
    MainLogView()
        .environment(\.logRepository, AppDependencies.live.logRepository)
        .environment(\.authService, AppDependencies.live.authService)
}
