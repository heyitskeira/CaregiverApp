import SwiftUI
import PhotosUI

struct PatientInfoView: View {
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
    
    @Environment(AppRouter.self) private var router
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 12) {
                    Text("Patient Information")
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(
                        "To create care group please tell us about the elderly receiving care"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title3)
                }
                
                Button(action: { showImagePicker = true }) {
                    ZStack(alignment: .bottomTrailing) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 44))
                                )
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
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField("Full Name", text: $fullName)
                            .textContentType(.name)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )

                    HStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField("Date of Birth", text: $dob)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )

                    Text("Basic Information")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 2)
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField("Gender", text: $gender)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )

                    HStack(spacing: 16) {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField("Blood Type", text: $bloodType)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )

                    HStack(spacing: 16) {
                        Image(systemName: "ruler")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField("Height (cm)", text: $height)
                            .keyboardType(.numberPad)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )

                    Text("Health Details")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 2)
                    HStack(spacing: 16) {
                        Image(systemName: "bandage.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField("Allergies", text: $allergies)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )
                    HStack(spacing: 16) {
                        Image(systemName: "heart.text.square")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField("Favorite Food", text: $favoriteFood)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )
                    HStack(spacing: 16) {
                        Image(systemName: "stethoscope")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)
                        TextField(
                            "Health Profile (e.g. Having cancer)",
                            text: $healthProfile
                        )
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )

                }.padding(.vertical, 24)

                Button(action: {
                    // Handle create care group
                    router.screen = .successCreate
                }) {
                    Text("Create Care Group")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
    }
}

#Preview {
    PatientInfoView()
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
