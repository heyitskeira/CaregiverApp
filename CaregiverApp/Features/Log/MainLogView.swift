//
//  MainLogView.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 03/06/26.
//

import SwiftUI

struct MainLogView: View {
    
    @State private var showingAddLog = false
    
    @State private var logs: [Log] = []
        
    var body: some View {
        Text("Logs")
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        
        NavigationStack{
            
            Text("Logs")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Button {
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
            .padding(.vertical)
            
            if logs.isEmpty {

                Spacer()

                VStack(spacing: 10) {

                    Image(systemName: "square.and.pencil")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .opacity(0.4)

                    VStack (spacing: 7){
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
                    LazyVStack {
                        ForEach(logs) { log in
                            LogPost(log: log)

                            Divider()
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 12)
                
            }
        }
        .sheet(isPresented: $showingAddLog) {
            AddLogSheetView { newLog in
                logs.insert(newLog, at: 0)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    MainLogView()
}
