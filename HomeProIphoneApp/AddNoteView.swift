//
//  AddNoteView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 1/10/26.
//

import SwiftUI
import FirebaseAuth

struct AddNoteView: View {
    let homeId: String?
    let homeItemId: String?
    let onNoteSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var noteBody: String = ""
    @State private var selectedNoteType: NoteType = .general
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section("Note Details") {
                    TextField("Title (optional)", text: $title)
                        .font(DesignSystem.Typography.body)

                    ZStack(alignment: .topLeading) {
                        if noteBody.isEmpty {
                            Text("Enter your note...")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }

                        TextEditor(text: $noteBody)
                            .font(DesignSystem.Typography.body)
                            .frame(minHeight: 120)
                    }

                    Picker("Note Type", selection: $selectedNoteType) {
                        ForEach(NoteType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.iconName)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                await saveNote()
                            }
                        }
                        .foregroundColor(DesignSystem.Colors.primary)
                        .disabled(noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .disabled(isLoading)
        }
    }

    private func saveNote() async {
        guard !noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                errorMessage = "Note body cannot be empty"
            }
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        guard let user = Auth.auth().currentUser else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Not authenticated"
            }
            return
        }

        do {
            let firebaseToken = try await user.getIDToken()

            let request = CreateNoteRequest(
                homeId: homeId,
                homeItemId: homeItemId,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : title,
                body: noteBody.trimmingCharacters(in: .whitespacesAndNewlines),
                noteType: selectedNoteType
            )

            _ = try await APIService.shared.createNote(
                request: request,
                firebaseToken: firebaseToken
            )

            await MainActor.run {
                isLoading = false
                onNoteSaved()
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to save note: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    AddNoteView(
        homeId: "home-1",
        homeItemId: nil,
        onNoteSaved: { print("Note saved") }
    )
}
