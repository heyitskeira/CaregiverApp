//
//  OnboardingView.swift
//  CaregiverApp
//
//  Created by Dzikry Aji Santoso on 04/06/26.
//

import SwiftUI

private let pages = [
    OnboardingPage(
        title: "Caring for Elderly Loved Ones Shouldn’t Be Done Alone",
        subtitle: "Bring family and friends together to support aging parents, grandparents, and elderly loved ones.",
        imageName: "Onboarding1"
    ),
    OnboardingPage(
        title: "Share Care Tasks with Ease",
        subtitle: "Assign tasks, track progress, and stay updated in one place.",
        imageName: "Onboarding2"
    ),
    OnboardingPage(
        title: "Build Your Care Group With Family and Friends",
        subtitle: "Create a care group or join an existing one in seconds. Coordinate care with family and friends for your elderly loved one.",
        imageName: "Onboarding3"
    )
]

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var onboardingFinished: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button("Skip") {
                    onboardingFinished = true
                }
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            }

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    VStack(spacing: 20
                    ) {
                        // Illustration (replace with your animated asset)
                        Image(page.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .foregroundColor(.accentColor)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.easeInOut, value: currentPage)

                        VStack(spacing: 0) {
                            Spacer()
                            Text(page.title)
                                .font(.title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .foregroundStyle(.accent)
                            Spacer()
                            Text(page.subtitle)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 216)
                        .padding(.horizontal)
                    }
                    .padding(.horizontal, 24)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Progress Indicator
            HStack(spacing: 12) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .frame(width: i == currentPage ? 36 : 16, height: 8)
                        .foregroundColor(i == currentPage ? .accentColor : .gray.opacity(0.4))
                        .scaleEffect(i == currentPage ? 1.2 : 1.0)
                        .animation(.spring(), value: currentPage)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
            
            Spacer()

            Button(action: {
                if currentPage < pages.count - 1 {
                    currentPage += 1
                } else {
                    onboardingFinished = true
                }
            }) {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }.padding(.horizontal, 16)
    
    }
}
