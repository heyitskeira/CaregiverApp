import SwiftUI

struct JoinCareGroupView: View {
    @State private var code: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var pasteAlert = false
    
    
    
    var body: some View {
        VStack() {
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
                            })
                        )
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
                Button(action: {
                    if let paste = UIPasteboard.general.string, paste.count == 6 {
                        for (idx, char) in paste.prefix(6).enumerated() {
                            code[idx] = String(char).uppercased()
                        }
                    } else {
                        pasteAlert = true
                    }
                }){
                    HStack (spacing: 16) {
                        Image(systemName: "document.on.clipboard.fill")
                        Text("Paste Code")
                    }.padding()
                }
                .alert("Clipboard does not contain a valid code.", isPresented: $pasteAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
            .padding(.vertical, 146)
            
            
            Button(action: {
                // Handle join group
            }) {
                Text("Join Care Group")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 60)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    JoinCareGroupView()
}
