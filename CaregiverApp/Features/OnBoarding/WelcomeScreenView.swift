import SwiftUI

struct WelcomeScreenView: View {
    var body: some View {
        ZStack {
            // Background gradient and shapes
            Color(red: 234 / 255, green: 241 / 255, blue: 250 / 255).ignoresSafeArea()
            
            GeometryReader { geo in
                // Decorative shapes (mimic blob/wave background)
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color(red: 234 / 255, green: 241 / 255, blue: 250 / 255)                            ],
                            startPoint: .top,
                            endPoint: UnitPoint(x:0.5, y :0.8)
                        )
                    )
                    .frame(width: 150, height: 100)
                    .offset(x: 300, y: -9)
                    .blur(radius: 10)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color(red: 234 / 255, green: 241 / 255, blue: 250 / 255)
                            ],
                            startPoint: .top,
                            endPoint: UnitPoint(x:0.5, y :0.8)
                        )
                    )
                    .frame(width: 120)
                    .offset(x: -80, y: 150)
                    .blur(radius: 10)

                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color(red: 234 / 255, green: 241 / 255, blue: 250 / 255)
                            ],
                            startPoint: .top,
                            endPoint: UnitPoint(x:0.5, y :0.8)                        )
                    )
                    .frame(width: 140, height: 200)
                    .offset(x: geo.size.width - 50, y: geo.size.height - 400)
                    .blur(radius: 10)

                RoundedRectangle(cornerRadius: 60)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color(red: 234 / 255, green: 241 / 255, blue: 250 / 255)
                            ],
                            startPoint: .top,
                            endPoint: UnitPoint(x:0.5, y :0.7)
                        )
                    )
                    .frame(width: 180, height: 180)
                    .offset(x: -90, y: geo.size.height - 100)
                    .blur(radius: 10)
            }

            VStack(spacing: 126) {
                Spacer()
                VStack(spacing: 32){
                    // Logo placeholder
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 200, height: 200)
                        .overlay(Text("Logo").font(.title3).foregroundColor(.white))
                    VStack(spacing: 12) {
                        VStack {
                            Text("Welcome to")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.primary)
                            
                            Text("Caregiver APP")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.accent)
                        }
                        
                        VStack{
                            Text("Coordinate Care. Share Tasks.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                            Text("Stay Connected.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                        }
                    }
                }
                VStack(spacing: 16) {
                    Button(action: {
                        // Handle create account
                    }) {
                        Text("Create Account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    
                    Button(action: {
                        // Handle sign in
                    }) {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.clear)
                            .foregroundColor(.accentColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 60)
                
                Spacer()
            }
        }
    }
}

#Preview {
    WelcomeScreenView()
}
