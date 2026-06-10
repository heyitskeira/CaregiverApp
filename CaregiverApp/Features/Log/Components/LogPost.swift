//
//  LogPost.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 03/06/26.
//

import SwiftUI
import Combine

struct LogPost: View {
    
    let log: Log
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    @State private var hasAcknowledged = false
    @State private var hasLiked = false
    
    @State private var relativeTime = ""

    private let timer = Timer.publish(
        every: 15,
        on: .main,
        in: .common
    ).autoconnect()
    
    private func updateRelativeTime() {
        relativeTime = log.timestamp.formatted(
            .relative(
                presentation: .named,
                unitsStyle: .abbreviated
            )
        )
    }
    
    var body: some View {
        HStack (alignment: .top, spacing: 8){
            
            Image(systemName: "person.crop.circle.fill")
                .font(.largeTitle)
            
            VStack (alignment: .leading){
                
                HStack{
                    HStack{
                        Text(log.author.name)
                            .font(.body)
                            .fontWeight(.semibold)
                        
                        Text(relativeTime)
                            .font(.body)
                            .opacity(0.5)
                            .padding(.trailing)
                            .onAppear {
                                updateRelativeTime()
                            }
                            .onReceive(timer) { _ in
                                updateRelativeTime()
                            }
                    }
                    
                    Spacer()
                    
//                    Image(systemName: "ellipsis")
//                        .font(.body)
//                        .fontWeight(.semibold)
                    
                    Menu {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Log", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .alert(
                        "Delete this log?",
                        isPresented: $showingDeleteConfirmation
                    ) {

                        Button("Delete", role: .destructive) {
                            onDelete()
                        }

                        Button("Cancel", role: .cancel) { }

                    }
                    
                }
                .padding(.bottom, 4)
                
                Text(log.content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing)
                
                if !log.images.isEmpty {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack {
                            
                            ForEach(log.images.indices, id: \.self) { index in
                                
                                Image(uiImage: log.images[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                            }
                        }
                    }
                }
                
                HStack (spacing: 10){
                    Button {
                        hasLiked.toggle()
                    } label: {
                        
                        Label(
                            "3",
                            systemImage:
                                hasLiked
                            ? "heart.fill"
                            : "heart"
                        )
                    }
                    .buttonStyle(.plain)
                    .tint(.green)
                    
                    Button {
                        hasAcknowledged.toggle()
                    } label: {
                        
                        Label(
                            "3",
                            systemImage:
                                hasAcknowledged
                            ? "eye.fill"
                            : "eye"
                        )
                    }
                    .buttonStyle(.plain)
                    .tint(.green)
                    
                    Spacer()
                    
                    Text(log.timestamp.formatted(
                        date: .omitted,
                        time: .shortened)
                    )
                    .font(.body)
                    .opacity(0.5)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    
    let sampleContact = CareContact(
        careTeamID: UUID(),
        name: "Sarah Antoso",
        relationship: "Primary Caregiver"
    )
    
    let sampleLog = Log(
        author: sampleContact,
        content: "Grandma suddenly coughed blood."
    )
    
    LogPost(log: sampleLog, onDelete: {})
    
}

