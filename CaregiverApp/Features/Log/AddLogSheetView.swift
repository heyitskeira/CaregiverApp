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
    
    var body: some View {
        NavigationStack{
            VStack{
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
                            
                            ForEach(selectedImages.indices, id: \.self) { index in

                                ZStack(alignment: .topTrailing) {

                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: .infinity, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    Button {

                                        selectedImages.remove(at: index)
                                        selectedPhotos.remove(at: index)
                                        
                                    } label: {

                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                }
                            }
                            
                            PhotosPicker(
                                selection: $selectedPhotos,
                                maxSelectionCount: 5,
                                matching: .images
                            ) {
                                
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
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

                    Button{} label:{
                        Text("Upload")
                    }
                }
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
    AddLogSheetView()
}
