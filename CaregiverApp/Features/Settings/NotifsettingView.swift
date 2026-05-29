//
//  NotifsettingView.swift
//  CaregiverApp
//
//  Created by Keira on 28/05/26.
//

import SwiftUI

struct NotifsettingView: View {
    
    @State private var isEnableReq = true
    @State private var isEnableTone = true
    
    
    var body: some View {
        List{
            Section (header: Text("")){
                VStack (alignment: .leading){
                    Toggle("Request", isOn: $isEnableReq)
                    Text("Receive task requests")
                        .foregroundStyle(Color.secondary)
                }
                VStack (alignment: .leading){
                    Toggle("Dial tone", isOn: $isEnableTone)
                    Text("Play sound whenever new notification pops up")
                        .foregroundStyle(Color.secondary)
                        .padding(.trailing, 80)
                }
            }
        }
    }
}

#Preview {
    NotifsettingView()
}
