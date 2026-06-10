import SwiftUI

struct JoinCareGroupView: View {
    @Environment(SessionStore.self) private var session

    @State private var code: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var pasteAlert = false
    @State private var showSuccess = false
    @State private var isLoading = false

    private var fullCode: String { code.joined() }

    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text("Join Care Group")
                    .font(.largeTitle).bold()
                    .foregroundStyle(Color.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Enter care group code shared by the primary caregiver")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title3)
            }.padding(.vertical, 12)

            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    ForEach(0..<6) { i in
                        TextField("", text: Binding(
                            get: { code[i] },
                            set: { newValue in
                                if newValue.count <= 1 {
                                    code[i] = newValue.uppercased()
                                    if !newValue.isEmpty && i < 5 { focusedIndex = i + 1 }
                                }
                            }
                        ))
                        .keyboardType(.asciiCapable)
                        .multilineTextAlignment(.center)
                        .font(.title).bold()
                        .frame(width: 40, height: 70)
                        .background(Color.accent.opacity(0.1))
                        .foregroundStyle(Color.accentColor)
                        .cornerRadius(8)
                        .focused($focusedIndex, equals: i)
                    }
                }
                Button {
                    if let paste = UIPasteboard.general.string, paste.count == 6 {
                        for (idx, char) in paste.prefix(6).enumerated() {
                            code[idx] = String(char).uppercased()
                        }
                    } else {
                        pasteAlert = true
                    }
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "document.on.clipboard.fill")
                        Text("Paste Code")
                    }.padding()
                }
                .alert("Clipboard does not contain a valid code.", isPresented: $pasteAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
            .padding(.vertical, 60)

            if let error = session.careGroupError {
                Text(error).foregroundStyle(.red).font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 8)
            }

            Button {
                isLoading = true
                Task {
                    await session.joinCareGroup(code: fullCode)
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
                        Text("Join Care Group").fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity).padding()
                .background(Color.accentColor).foregroundColor(.white).clipShape(Capsule())
            }
            .disabled(isLoading || fullCode.count < 6)
            .padding(.bottom, 60)

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showSuccess) {
            CareGroupJoinedView()
        }
    }
}

#Preview {
    JoinCareGroupView().environment(SessionStore())
}
