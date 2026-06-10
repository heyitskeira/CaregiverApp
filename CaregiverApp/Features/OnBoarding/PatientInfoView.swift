import PhotosUI
import SwiftUI

struct PatientInfoView: View {
    // MARK: - State
    @State private var fullName = ""
    @State private var dob: Date = Date()
    @State private var gender = ""
    @State private var bloodType = ""
    @State private var height: Double? = nil
    @State private var weight: Double? = nil
    @State private var allergies = ""
    @State private var favoriteFood = ""
    @State private var healthProfile = ""

    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false

    // MARK: - Constants
    let genderOptions = ["", "Male", "Female"]
    let bloodTypeOptions = [
        "", "A+", "B+", "AB+", "O+", "A-", "B-", "AB-", "O-",
    ]

    // MARK: - Environment

    @Environment(AppRouter.self) private var router
    @Environment(SupabaseAuthService.self) private var authService
    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - Computed

    private var isFormComplete: Bool {
        guard
            !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !gender.isEmpty,
            gender != "",
            !bloodType.isEmpty,
            bloodType != ""
        else { return false }
        return true
    }

    // MARK: - Body

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
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 34, height: 34)
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
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
                        Text("Date of Birth").frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        ).foregroundStyle(Color(.secondaryLabel))

                        DatePicker(
                            "",
                            selection: $dob,
                            displayedComponents: .date
                        )
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
                        Image(
                            systemName:
                                "figure.stand.dress.line.vertical.figure"
                        )
                        .foregroundColor(.accentColor)
                        .frame(width: 22)

                        Text("Gender")
                            .foregroundStyle(Color.secondary)

                        Picker("Gender", selection: $gender) {
                            ForEach(genderOptions, id: \.self) { option in
                                if option.isEmpty {
                                    Text("Select Gender")
                                        .tag(option)
                                        .disabled(true)
                                } else {
                                    Text(option).tag(option)
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
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

                        Text("Blood Type")
                            .foregroundStyle(Color.secondary)

                        Picker("Blood Type", selection: $bloodType) {
                            ForEach(bloodTypeOptions, id: \.self) { option in
                                if option.isEmpty {
                                    Text("Select Blood Type")
                                        .tag(option)
                                        .disabled(true)
                                } else {
                                    Text(option).tag(option)
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
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

                        TextField(
                            "Height (cm)",
                            value: $height,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                    }
                    .frame(height: 22)
                    .padding(10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )

                    HStack(spacing: 16) {
                        Image(systemName: "scalemass")
                            .foregroundColor(.accentColor)
                            .frame(width: 22)

                        TextField(
                            "Weight (kg)",
                            value: $weight,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
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
                        Image(systemName: "fork.knife")
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
                }
                .padding(.vertical, 24)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: {
                    isLoading = true
                    errorMessage = nil
                    Task {
                        do {
                            _ = try await authService.createCareTeam(
                                name: "\(fullName)'s Care Team",
                                patientName: fullName,
                                patientDOB: dob
                            )
                            router.screen = .successCreate
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                }) {
                    if isLoading {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.accentColor).clipShape(Capsule())
                    } else {
                        Text("Create Care Group")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white).clipShape(Capsule())
                    }
                }
                .disabled(!isFormComplete || isLoading)
                .opacity(isFormComplete ? 1 : 0.5)
            }
            .padding()
        }
    }
}

#Preview {
    let router = AppRouter()
    PatientInfoView()
        .environment(router)
        .environment(SupabaseAuthService())
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UINavigationControllerDelegate,
        UIImagePickerControllerDelegate
    {
        let parent: ImagePicker

        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController
                .InfoKey: Any]
        ) {
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

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}
}
