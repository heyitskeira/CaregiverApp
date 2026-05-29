//
//  PreferenceSection.swift
//  CaregiverApp
//
//  Created by Keira on 28/05/26.
//

import SwiftUI

struct PreferenceList: View {
    var menuImage: String
    var menuName: String
    
    var body: some View {
        HStack {
            Image(systemName: menuImage)
                .foregroundStyle(.tint)
                .bold()
                .background(Circle().fill(Color.accentColor.opacity(0.1)).frame(width: 30, height: 30))
            Text(menuName)
        }
    }
}


