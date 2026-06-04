import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            HStack {
                Text("Inbox")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Divider().padding(.vertical, 10)
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "hand.wave.fill")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.orange.opacity(0.8))
                            .clipShape(Circle())
                        
                        Text("5 task request")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Accept All") {
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    ForEach(0..<5) { _ in
                        InboxRow()
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct InboxRow: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                
                Image(systemName: "hand.raised.fill")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.orange.opacity(0.8))
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hospital Visit")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("27 May 2026")
                    .font(.subheadline)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.orange.opacity(0.8))
                    Text("05.00-05.30 (2 hr)")
                        .foregroundColor(.gray)
                }
                .font(.caption)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
        
        Divider().padding(.leading, 70)
    }
}

#Preview {
    InboxView()
}
