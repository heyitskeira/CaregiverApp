//
//  PatientdetailView.swift
//  CaregiverApp
//
//  Created by Keira on 28/05/26.
//

import SwiftUI

struct PatientdetailView: View {
    @Environment(\.patientRepository) private var patientRepository
    
    @State var patientdetail: CareRecipient
    @State private var isShowingEditView = false
    
    var body: some View {
        VStack {
            HStack{
                Text("Patient")
                    .font(.largeTitle)
                    .bold()
                    .padding(2)
                
                Spacer()
                Button(action: {
                    isShowingEditView = true
                }) {
                    Text("Edit")
                        .fontWeight(.medium)
                }
                .padding(.trailing, 5)
            }
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 370, height: 100)
                    .foregroundColor(.accentColor.opacity(0.15))
                    .padding(10)
                
                HStack{
                    Image("profile1")
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .leading)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .padding(.trailing, 10)
                    VStack (alignment: .leading){
                        Text(patientdetail.name)
                            .fontWeight(.bold)
                        Text( "\(patientdetail.ageInYears) years old")
                            .font(.caption)
                        
                    }
                    Spacer()
                }
                .padding(20)
            }
            
            List{
                Section(header: Text("Basic Information").foregroundStyle(Color.black)){
                    PatientDetailList(menuName: "Date of Birth", menuImage: "calendar", menuData: patientdetail.dateOfBirthString)
                    PatientDetailList(menuName: "Gender", menuImage: "figure.stand.dress.line.vertical.figure", menuData: patientdetail.gender)
                    PatientDetailList(menuName: "Blood Type", menuImage: "drop", menuData: patientdetail.bloodType)
                }
                
                Section(header: Text("Health Information").foregroundStyle(Color.black)){
                    PatientDetailList(menuName: "Allergies", menuImage: "exclamationmark.square.fill", menuData: patientdetail.allergies)
                    PatientDetailList(menuName: "Favorite Food", menuImage: "fork.knife", menuData: patientdetail.favoriteFood)
                    VStack (alignment: .leading){
                        PatientDetailList(menuName: "Health Profile", menuImage: "text.document", menuData: "")
                        Text(patientdetail.healthNotes)
                            .font(Font.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            //            .scrollContentBackground(.hidden)
        }
        .padding()
        
        .sheet(isPresented: $isShowingEditView) {
            PatientEditView(patient: $patientdetail)
        }
    }
}

#Preview {
    PatientdetailView(patientdetail: SeedData.patient)
}
