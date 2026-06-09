//
//  TaskCompletionPopupView.swift
//  CaregiverApp
//
//  A pop-up for submitting logs after completing a task.
//

import SwiftUI
import PhotosUI

struct TaskCompletionPopupView: View {
    var taskTitle: String = ""
    @State private var notes: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var attachedImages: [UIImage] = []
    @State private var isFilePickerPresented = false
    @State private var fileAttachments: [TaskAttachment] = []

    private let brandBlue = Color(hex: 0x2051B9)

    var onPost: ((String, [UIImage]) -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Completed!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("Add notes for your team about\nhow \"\(taskTitle)\" went.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)

            // Notes Field
            TextField("Add Notes", text: $notes, axis: .vertical)
                .lineLimit(3...5)
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            // Attachment buttons (same format as TaskSheetView)
            VStack(spacing: 0) {
                Button(action: { isFilePickerPresented = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "paperclip")
                            .foregroundStyle(brandBlue)
                        Text("Add Attachment...")
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 44)

                PhotosPicker(selection: $selectedItems, matching: .images) {
                    HStack(spacing: 10) {
                        Image(systemName: "photo")
                            .foregroundStyle(brandBlue)
                        Text("Add Picture...")
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .onChange(of: selectedItems) { _, newItems in
                    Task {
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    attachedImages.append(uiImage)
                                }
                            }
                        }
                        await MainActor.run {
                            selectedItems = []
                        }
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Attached images preview
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
                                    Button {
                                        withAnimation {
                                            _ = attachedImages.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white, .black.opacity(0.6))
                                            .padding(4)
                                    }
                                }
                        }
                    }
                }
            }

            // Buttons
            HStack(spacing: 12) {
                Button(action: { onCancel?() }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }

                Button(action: { onPost?(notes, attachedImages) }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(brandBlue)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(24)
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            if case .success(let urls) = result {
                for url in urls {
                    let attachment = TaskAttachment(
                        fileName: url.lastPathComponent,
                        fileType: AttachmentType.from(fileExtension: url.pathExtension),
                        localURL: url
                    )
                    fileAttachments.append(attachment)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3).ignoresSafeArea()
        TaskCompletionPopupView(taskTitle: "Give Meds")
    }
}
