//
//  SplashView.swift
//  JagaKin
//
//  Created by Dzikry Aji Santoso on 08/06/26.
//

import SwiftUI

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)

                Text("JagaKin")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.accent)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1
                opacity = 1
            }
        }
    }
}

#Preview {
    SplashView()
}
