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
    
    var onCancel: (() -> Void)? = nil
    var onPost: ((String, [UIImage]) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Add Task Log")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primaryText)
                
                Text("Share notes or photos.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.top, 10)
            
            TextField("Add Notes", text: $notes, axis: .vertical)
                .lineLimit(3...5)
                .padding(14)
                .background(AppTheme.pageBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading) {
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text(attachedImages.isEmpty ? "Add Pictures" : "Add More Pictures")
                    }
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(AppTheme.pageBackground)
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
            
            HStack(spacing: 16) {
                Button(action: { onCancel?() }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.pageBackground) // light gray/cream
                        .clipShape(Capsule())
                }
                
                Button(action: { onPost?(notes, attachedImages) }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.accentBlue)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 10)
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(24)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3).ignoresSafeArea()
        
        TaskCompletionPopupView()
    }
    .environment(\.colorScheme, .light)
}
