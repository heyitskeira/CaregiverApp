//
//  MainLogView.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 03/06/26.
//

import SwiftUI

struct MainLogView: View {
    
    @State private var showingAddLog = false
    
    var body: some View {
        
        NavigationStack{
            
            Button{
                showingAddLog = true
            } label:{
                HStack{
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                    
                    VStack (alignment: .leading){
                        Text("Sarah Antoso")
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
            
            ScrollView{
                
            }
        }
        .sheet(isPresented: $showingAddLog){
            AddLogSheetView()
        }
        .padding(.horizontal)
    }
}

#Preview {
    MainLogView()
}
