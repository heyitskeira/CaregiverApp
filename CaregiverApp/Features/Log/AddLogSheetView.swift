//
//  AddLogSheetView.swift
//  CaregiverApp
//

import SwiftUI
import PhotosUI

struct AddLogSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.authService) private var authService

    @State private var logContent = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    let onUpload: (Log) -> Void
    
    private let currentUser = CareContact(
        careTeamID: UUID(),
        name: "Sarah Antoso",
        relationship: "Primary Caregiver"
    )
    
    private let recipient = CareRecipient(
        careTeamID: UUID(),
        name: "Grandma Lily",
        dateOfBirth: .now,
        gender: "Female",
        bloodType: "O"
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Divider().padding(.bottom, 12)

                    HStack(alignment: .top, spacing: 12) {

//                        Image(systemName: "person.crop.circle.fill").font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading) {
//                                Text(authService.currentUser?.name ?? "Caregiver").fontWeight(.semibold)
                                TextField("What happened with \(recipient.name)?", text: $logContent, axis: .vertical)
                                    .lineLimit(1...10)
                            }
                            .padding(.bottom, 7)

                            if !selectedImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(selectedImages.indices, id: \.self) { index in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: selectedImages[index])
                                                    .resizable().scaledToFill()
                                                    .frame(width: 180, height: 120).clipped()
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                Button {
                                                    selectedImages.remove(at: index)
                                                    selectedPhotos.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.title3).foregroundStyle(.white)
                                                }
                                                .padding(8)
                                            }
                                        }
                                    }
                                }
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
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Text("Close") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let user = authService.currentUser
                        let authorContact = CareContact(
                            id: user?.id ?? UUID(),
                            careTeamID: SeedData.careTeamID,
                            name: user?.name ?? "Caregiver",
                            relationship: authService.currentRole == .primaryCaregiver ? "Primary Caregiver" : "Helper",
                            phone: user?.phone ?? "",
                            email: user?.email ?? ""
                        )
                        let newLog = Log(
                            author: authorContact,
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
                HStack(spacing: 20) {
                    Spacer()
                    
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color(hex: 0x2051B9)) // Brand Blue
                            .clipShape(Circle())
                            .shadow(radius: 2, y: 1)
                    }
                }
                .foregroundStyle(.primary)
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
    AddLogSheetView { _ in }
        .environment(\.authService, AppDependencies.live.authService)
}
