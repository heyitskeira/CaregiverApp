//
//  LogPost.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 03/06/26.
//

import SwiftUI

struct LogPost: View {
    
    let log: Log
    
    @State private var hasAcknowledged = false
    
    var body: some View {
        HStack (alignment: .top, spacing: 8){
            
            Image(systemName: "person.crop.circle.fill")
                .font(.largeTitle)
            
            VStack (alignment: .leading){
                
                HStack{
                    Text(log.author.name)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(log.timestamp.formatted(
                        date: .omitted,
                        time: .shortened)
                    )
                        .font(.caption)
                        .opacity(0.5)
                        .padding(.trailing)
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
                .padding(.top, 6)
            }
        }
    }
}

#Preview {
    
    let sampleContact = CareContact(
        name: "Sarah Antoso",
        relationship: "Primary Caregiver"
    )

    let sampleLog = Log(
        author: sampleContact,
        content: "Grandma suddenly coughed blood."
    )

    LogPost(log: sampleLog)

}
