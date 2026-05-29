//
//  PatientDetailList.swift
//  CaregiverApp
//
//  Created by Keira on 28/05/26.
//
import SwiftUI

struct PatientDetailList: View {
    
    var menuName: String
    var menuImage: String
    var menuData : String
    
    var body: some View {
        HStack {
            Image(systemName: menuImage)
                .font(.system(size: 10))
                .frame(width: 20, height: 20)
                .clipShape(Circle())
            
            Text(menuName)
                .font(.system(size: 12))
            
            Spacer()
            
            Text(menuData)
                .font(.system(size: 12))
        }
    }
}
