import SwiftUI

/// Temporary settings shell until the Settings feature owner integrates the full screen.
struct SettingsRootView: View {
    var body: some View {
        NavigationStack{
            HStack{
                Image("profile1")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .leading)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding(.trailing, 15)
                    .padding(.bottom, 15)
                
                VStack(alignment: .leading){
                    Text("Sarah Sechan")
                        .bold()
                    Text("primary caregiver")
                        .fixedSize(horizontal: true, vertical: true)
                        .background(Capsule().fill(Color.green.opacity(0.7)).frame(height: 22))
                    HStack{
                        Image(systemName: "phone")
                        Text ("+628123456789")
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 20)
            
            List {
                CareGroupSection()
                
                NavigationLink(destination:
                                PatientdetailView(patientdetail: SeedData.patient)){
                    Text("View Patient")
                }
                
                Section(header: Text("Preferences")){
                    NavigationLink(destination:             NotifsettingView()){
                        PreferenceList(menuImage: "bell", menuName: "Notification Presferences")
                    }
                    NavigationLink(destination:
                                    LangsettingView()){
                        PreferenceList(menuImage: "globe", menuName: "Language")}
                    NavigationLink(destination:
                                    PnSsetting()){
                        PreferenceList(menuImage: "lock", menuName: "Privacy & Security")}
                }
                
            }
        }
        
    }
}

#Preview {
    SettingsRootView()
}
