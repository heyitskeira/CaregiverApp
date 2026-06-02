//
//  PatientEditView.swift
//  CaregiverApp
//
//  Created by Keira on 01/06/26.
//

import SwiftUI

struct PatientEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.patientRepository) private var patientRepository
    
    @Binding var patient: CareRecipient
    
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var gender: String = ""
    @State private var bloodType: String = ""
    @State private var allergies: String = ""
    @State private var favoriteFood: String = ""
    @State private var healthNotes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    TextField("Gender", text: $gender)
                    TextField("Blood Type", text: $bloodType)
                }
                
                Section(header: Text("Health Information")) {
                    TextField("Allergies", text: $allergies)
                    TextField("Favorite Food", text: $favoriteFood)
                    
                    VStack(alignment: .leading) {
                        Text("Health Profile Notes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $healthNotes)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Edit Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
            .onAppear {
                name = patient.name
                dateOfBirth = patient.dateOfBirth
                gender = patient.gender
                bloodType = patient.bloodType
                allergies = patient.allergies
                favoriteFood = patient.favoriteFood
                healthNotes = patient.healthNotes
            }
        }
        
    }
    
    private func saveChanges() {
        patient.name = name
        patient.dateOfBirth = dateOfBirth
        patient.gender = gender
        patient.bloodType = bloodType
        patient.allergies = allergies
        patient.favoriteFood = favoriteFood
        patient.healthNotes = healthNotes
        
        dismiss()
    }
    
}
