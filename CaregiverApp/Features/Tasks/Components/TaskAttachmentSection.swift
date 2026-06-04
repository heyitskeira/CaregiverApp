//
//  TaskAttachmentSection.swift
//  CaregiverApp
//
//  Attachment & Notes section for the task sheet with photo/video picker
//  and tap-to-preview for attached files.
//

import SwiftUI
import PhotosUI

struct TaskAttachmentSection: View {
    let isEditing: Bool
    @Binding var taskNote: String
    @Binding var attachedImages: [UIImage]

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var previewImage: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Attachment & Notes")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primaryText)
                .padding(.horizontal)
                .padding(.bottom, 12)

            // Attached images preview
            if !attachedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(attachedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: attachedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        previewImage = attachedImages[index]
                                    }

                                if isEditing {
                                    Button {
                                        let idx = index
                                        withAnimation {
                                            _ = attachedImages.remove(at: idx)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(.black.opacity(0.6)).frame(width: 20, height: 20))
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)
            }

            // Add file button (photo/video picker)
            if isEditing {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 10,
                    matching: .any(of: [.images, .videos])
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperclip")
                            .font(.body)
                            .foregroundStyle(Color.accentColor)
                        Text("Add file")
                            .font(.subheadline)
                            .foregroundStyle(Color.accentColor)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 12)
                .onChange(of: selectedPhotos) { _, newItems in
                    Task {
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                attachedImages.append(image)
                            }
                        }
                        selectedPhotos = []
                    }
                }
            } else if attachedImages.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "paperclip")
                        .font(.body)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("No files attached")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }

            // Notes text field
            if isEditing {
                TextField(
                    "Add notes, links, or phone numbers...",
                    text: $taskNote,
                    axis: .vertical
                )
                .font(.subheadline)
                .foregroundStyle(AppTheme.primaryText)
                .padding(12)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )
                .padding(.horizontal)
                .lineLimit(3...6)
            } else {
                Text(taskNote.isEmpty ? "No notes added" : taskNote)
                    .font(.subheadline)
                    .foregroundStyle(taskNote.isEmpty ? AppTheme.secondaryText : AppTheme.primaryText)
                    .padding(.horizontal)
            }
        }
        .fullScreenCover(item: Binding(
            get: { previewImage.map { IdentifiableImage(image: $0) } },
            set: { previewImage = $0?.image }
        )) { item in
            ImagePreviewView(image: item.image) {
                previewImage = nil
            }
        }
    }
}

// MARK: - Identifiable wrapper for UIImage
private struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - Fullscreen Image Preview
struct ImagePreviewView: View {
    let image: UIImage
    var onDismiss: (() -> Void)? = nil

    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = value.magnification
                        }
                        .onEnded { _ in
                            withAnimation {
                                scale = max(1.0, min(scale, 3.0))
                            }
                        }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.trailing, 20)
            .padding(.top, 60)
        }
    }
}
