////
////  CameraView.swift
////  CaregiverApp
////
////  Created by Christopher Jonathan on 10/06/26.
////
//
//import SwiftUI
//
//struct CameraView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    let onCapture: (UIImage) -> Void
//
//    @StateObject private var camera = CameraManager()
//
//    var body: some View {
//
//        ZStack {
//
//            CameraPreview(session: camera.session)
//                .ignoresSafeArea()
//
//            VStack {
//
//                Spacer()
//
//                Button {
//
//                    camera.capturePhoto()
//
//                } label: {
//
//                    Circle()
//                        .fill(.white)
//                        .frame(width: 80, height: 80)
//
//                }
//                .padding(.bottom, 40)
//            }
//        }
//    }
//}
