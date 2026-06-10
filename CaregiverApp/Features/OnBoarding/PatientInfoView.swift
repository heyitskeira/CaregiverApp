import SwiftUI
import PhotosUI

struct PatientInfoView: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var dob = ""
    @State private var gender = ""
    @State private var bloodType = ""
    @State private var height = ""
    @State private var allergies = ""
    @State private var favoriteFood = ""
    @State private var healthProfile = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showSuccess = false
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 12) {
                    Text("Patient Information")
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("To create care group please tell us about the elderly receiving care")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                }

                Button { showImagePicker = true } label: {
                    ZStack(alignment: .bottomTrailing) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable().scaledToFill()
                                .frame(width: 100, height: 100).clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color(.systemGray5)).frame(width: 100, height: 100)
                                .overlay(Image(systemName: "person.fill").foregroundColor(.gray).font(.system(size: 44)))
                        }
                        ZStack {
                            Circle().fill(Color.accentColor).frame(width: 34, height: 34)
                            Image(systemName: "camera.fill").foregroundColor(.white).font(.system(size: 16, weight: .bold))
                        }
                        .offset(x: 4, y: 6)
                    }
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
                .padding(.bottom, 8)

                VStack(alignment: .leading, spacing: 16) {
                    inputField(icon: "person.fill", placeholder: "Full Name", text: $fullName)
                    inputField(icon: "calendar", placeholder: "Date of Birth", text: $dob)

                    Text("Basic Information").font(.headline).foregroundColor(.primary).padding(.bottom, 2)
                    inputField(icon: "person.circle", placeholder: "Gender", text: $gender)
                    inputField(icon: "drop.fill", placeholder: "Blood Type", text: $bloodType)
                    inputField(icon: "ruler", placeholder: "Height (cm)", text: $height, keyboard: .numberPad)

                    Text("Health Details").font(.headline).foregroundColor(.primary).padding(.bottom, 2)
                    inputField(icon: "bandage.fill", placeholder: "Allergies", text: $allergies)
                    inputField(icon: "heart.text.square", placeholder: "Favorite Food", text: $favoriteFood)
                    inputField(icon: "stethoscope", placeholder: "Health Profile (e.g. Having cancer)", text: $healthProfile)
                }
                .padding(.vertical, 24)

                if let error = session.careGroupError {
                    Text(error).foregroundStyle(.red).font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 8)
                }

                Button {
                    isLoading = true
                    Task {
                        await session.createCareGroup(patientName: fullName)
                        isLoading = false
                        if session.careGroupError == nil {
                            showSuccess = true
                        }
                    }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Create Care Group").fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.accentColor).foregroundColor(.white).clipShape(Capsule())
                }
                .disabled(isLoading)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showSuccess) {
            CareGroupCreatedView()
        }
    }

    @ViewBuilder
    private func inputField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon).foregroundColor(.accentColor).frame(width: 22)
            TextField(placeholder, text: text).keyboardType(keyboard)
        }
        .frame(height: 22).padding(10).cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))
    }
}

#Preview {
    PatientInfoView().environment(SessionStore())
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage { parent.image = uiImage }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
