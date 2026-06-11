//
//  PatientdetailView.swift
//  CaregiverApp
//

import SwiftUI

struct PatientdetailView: View {
    @Environment(\.patientRepository) private var patientRepository
    @Environment(\.authService) private var authService

    @State var patientdetail: CareRecipient
    @State private var isShowingEditView = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack {
                
                ProfileHeader(
                    title: patientdetail.name,
                    subTitle: "\(patientdetail.ageInYears) years old"
                )


                List {
                    Section(header: Text("Health Information")) {
                        PatientDetailList(
                            menuName: "Allergies",
                            menuImage: "bandage",
                            menuData: patientdetail.allergies
                        )
                        PatientDetailList(
                            menuName: "Favorite Food",
                            menuImage: "fork.knife",
                            menuData: patientdetail.favoriteFood
                        )
                        VStack(alignment: .leading) {
                            PatientDetailList(
                                menuName: "Health Profile",
                                menuImage: "text.document",
                                menuData: ""
                            )
                            Text(patientdetail.healthNotes)                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Section(header: Text("Basic Information")) {
                        PatientDetailList(
                            menuName: "Date of Birth",
                            menuImage: "calendar",
                            menuData: patientdetail.dateOfBirthString
                        )
                        PatientDetailList(
                            menuName: "Gender",
                            menuImage:
                                "figure.stand.dress.line.vertical.figure",
                            menuData: patientdetail.gender
                        )
                        PatientDetailList(
                            menuName: "Blood Type",
                            menuImage: "drop",
                            menuData: patientdetail.bloodType
                        )
                    }

                    
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                PatientEditView(patient: $patientdetail)
            }
            .navigationTitle("Patient Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                if authService.currentRole.canEditTask {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            isShowingEditView = true
                        }.tint(.accentColor)
                    }
                }
            })
        }
    }
}

#Preview {
    NavigationStack {
        PatientdetailView(patientdetail: SeedData.patient)
    }
    .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
