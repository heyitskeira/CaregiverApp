//
//  AddLogSheetView.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 03/06/26.
//

import SwiftUI

import PhotosUI

struct AddLogSheetView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var logContent = ""
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    let onUpload: (Log) -> Void
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    
                    Divider()
                        .padding(.bottom, 12)
                    
                    HStack(alignment: .top, spacing: 12) {
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            
                            VStack(alignment: .leading){
                                Text("Sarah Antoso")
                                    .fontWeight(.semibold)
                                
                                TextField(
                                    "What's happening?",
                                    text: $logContent,
                                    axis: .vertical
                                )
                                .lineLimit(1...10)
                            }
                            .padding(.bottom, 7)
                            
                            if !selectedPhotos.isEmpty {
                                
                                Text("\(selectedPhotos.count) photo(s) selected")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !selectedImages.isEmpty {

                                ScrollView(.horizontal, showsIndicators: false) {

                                    HStack(spacing: 12) {

                                        ForEach(selectedImages.indices, id: \.self) { index in

                                            ZStack(alignment: .topTrailing) {

                                                Image(uiImage: selectedImages[index])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 180, height: 120)
                                                    .clipped()
                                                    .clipShape(
                                                        RoundedRectangle(cornerRadius: 12)
                                                    )

                                                Button {

                                                    selectedImages.remove(at: index)
                                                    selectedPhotos.remove(at: index)

                                                } label: {

                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.title3)
                                                        .foregroundStyle(.white)

                                                }
                                                .padding(8)

                                            }

                                        }

                                    }

                                }

                            }
                            
//                            PhotosPicker(
//                                selection: $selectedPhotos,
//                                maxSelectionCount: 5,
//                                matching: .images
//                            ) {
//                                
//                                Image(systemName: "photo")
//                                    .font(.title2)
//                                    .foregroundStyle(.secondary)
//                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Log")
            .toolbarTitleDisplayMode(.inline) 
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    
                    Button{
                        dismiss()
                    } label:{
                        Text("Close")
                    }
                }
                
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {

                        let testUser = CareContact(
                            careTeamID: UUID(),
                            name: "Sarah Antoso",
                            relationship: "Primary Caregiver"
                        )

                        let newLog = Log(
                            author: testUser,
                            content: logContent,
                            images: selectedImages
                        )

                        onUpload(newLog)

                        dismiss()

                    } label: {
                        Text("Upload")
                    }
                    .disabled(
                        logContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        && selectedImages.isEmpty
                    )
                }
            }
            .safeAreaInset(edge: .bottom) {

                HStack {

                    Spacer()

                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {

                        Image(systemName: "photo")
                            .font(.title2)
                            .padding(16)

                    }
                    .background(.regularMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 4)

                }
                .padding(.horizontal)
                .padding(.bottom, 8)

            }
            .onChange(of: selectedPhotos) {
                Task {
                    selectedImages.removeAll()

                    for item in selectedPhotos {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddLogSheetView { _ in

    }
}
