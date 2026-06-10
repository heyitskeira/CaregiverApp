import SwiftUI

struct WelcomeScreenView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                // Decorative shapes (mimic blob/wave background)
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color(.systemBackground)
                            ],
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
                                Color(.systemBackground)
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
                                Color(.systemBackground)
                            ],
                            startPoint: .top,
                            endPoint: UnitPoint(x:0.5, y :0.8)
                        )
                    )
                    .frame(width: 140, height: 200)
                    .offset(x: geo.size.width - 50, y: geo.size.height - 400)
                    .blur(radius: 10)

                RoundedRectangle(cornerRadius: 60)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color(.systemBackground)
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
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    VStack(spacing: 12) {
                        VStack {
                            Text("Welcome to")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.primary)
                            
                            Text("JagaKin")
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
                        router.screen = .signUp
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
                        router.screen = .signIn
                    }) {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.clear)
                            .foregroundColor(.accentColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.accentColor, lineWidth: 1)
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
