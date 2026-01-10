//
//  CameraView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 1/6/26.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onImageCaptured: (UIImage) -> Void
    var onError: ((String) -> Void)?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        print("📸 CameraView: Making UIImagePickerController")

        // Check if camera is available
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌ Camera not available on this device")
            DispatchQueue.main.async {
                self.onError?("Camera is not available on this device")
                self.isPresented = false
            }
            return UIImagePickerController()
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen

        print("✅ Camera picker configured successfully")
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
            print("📸 CameraView Coordinator initialized")
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("📸 Image picker finished with image")
            if let image = info[.originalImage] as? UIImage {
                print("✅ Captured image size: \(image.size)")
                parent.onImageCaptured(image)
            } else {
                print("❌ Failed to get image from picker")
                parent.onError?("Failed to capture image")
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("📸 Image picker cancelled")
            parent.isPresented = false
        }
    }
}

struct CameraPermissionView: View {
    @Binding var isPresented: Bool
    @State private var permissionStatus: AVAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                Spacer()

                Image(systemName: "camera.fill")
                    .font(.system(size: 64))
                    .foregroundColor(DesignSystem.Colors.primary)

                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Camera Access Required")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text(permissionMessage)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                }

                if permissionStatus == .denied {
                    Button(action: openSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open Settings")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .primaryButtonStyle()
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                } else {
                    Button(action: requestPermission) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Allow Camera Access")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .primaryButtonStyle()
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }

                Spacer()
            }
            .navigationTitle("Camera Permission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            checkPermission()
        }
    }

    private var permissionMessage: String {
        switch permissionStatus {
        case .denied:
            return "Camera access was denied. Please enable it in Settings to take photos."
        case .restricted:
            return "Camera access is restricted on this device."
        default:
            return "This app needs access to your camera to take photos of your home items."
        }
    }

    private func checkPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                checkPermission()
                if granted {
                    isPresented = false
                }
            }
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
