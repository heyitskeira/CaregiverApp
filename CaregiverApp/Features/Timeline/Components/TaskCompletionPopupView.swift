//
//  TaskCompletionPopupView.swift
//  CaregiverApp
//
//  A pop-up for submitting logs after completing a task.
//

import SwiftUI
import PhotosUI

struct TaskCompletionPopupView: View {
    @State private var notes: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var attachedImages: [UIImage] = []
    
    var onPost: ((String, [UIImage]) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Please add the logs")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                Text("Write things that are important\nfor the others to know.")
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
            
            // Notes Field
            TextField("Add Notes", text: $notes, axis: .vertical)
                .lineLimit(3...5)
                .padding(16)
                .background(Color.black.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Pictures Field
            VStack(alignment: .leading) {
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    HStack {
                        Text(attachedImages.isEmpty ? "Add Pictures" : "Add More Pictures")
                        Spacer()
                    }
                    .font(.body)
                    .foregroundStyle(.black.opacity(0.4))
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                    .padding(16)
                    .background(Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .onChange(of: selectedItems) { oldValue, newValue in
                    Task {
                        var images: [UIImage] = []
                        for item in newValue {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                images.append(uiImage)
                            }
                        }
                        await MainActor.run {
                            attachedImages = images
                        }
                    }
                }
                
                // Show thumbnails
                if !attachedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(attachedImages.indices, id: \.self) { index in
                                Image(uiImage: attachedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(alignment: .topTrailing) {
                                        Button(action: {
                                            let idx = index
                                            withAnimation {
                                                _ = attachedImages.remove(at: idx)
                                                if idx < selectedItems.count {
                                                    _ = selectedItems.remove(at: idx)
                                                }
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .black.opacity(0.6))
                                                .padding(4)
                                        }
                                    }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            
            // Post Button
            Button(action: { onPost?(notes, attachedImages) }) {
                Text("Post")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color(red: 0.88, green: 0.95, blue: 0.95)) // Light pastel cyan/blue background
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(24)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3).ignoresSafeArea()
        TaskCompletionPopupView()
    }
}
