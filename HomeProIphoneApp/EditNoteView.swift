//
//  EditNoteView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 1/10/26.
//

import SwiftUI
import FirebaseAuth

struct EditNoteView: View {
    let note: Note
    let onNoteSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var noteBody: String
    @State private var selectedNoteType: NoteType
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(note: Note, onNoteSaved: @escaping () -> Void) {
        self.note = note
        self.onNoteSaved = onNoteSaved
        _title = State(initialValue: note.title ?? "")
        _noteBody = State(initialValue: note.body)
        _selectedNoteType = State(initialValue: note.noteType)
    }

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
            .navigationTitle("Edit Note")
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
                                await updateNote()
                            }
                        }
                        .foregroundColor(DesignSystem.Colors.primary)
                        .disabled(noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !hasChanges)
                    }
                }
            }
            .disabled(isLoading)
        }
    }

    private var hasChanges: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalTitle = note.title ?? ""
        let trimmedBody = noteBody.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmedTitle != originalTitle ||
               trimmedBody != note.body ||
               selectedNoteType != note.noteType
    }

    private func updateNote() async {
        guard !noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                errorMessage = "Note body cannot be empty"
            }
            return
        }

        guard hasChanges else {
            // No changes, just dismiss
            await MainActor.run {
                dismiss()
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

            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedBody = noteBody.trimmingCharacters(in: .whitespacesAndNewlines)

            let request = UpdateNoteRequest(
                title: trimmedTitle.isEmpty ? nil : trimmedTitle,
                body: trimmedBody,
                noteType: selectedNoteType
            )

            _ = try await APIService.shared.updateNote(
                noteId: note.id,
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
                errorMessage = "Failed to update note: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    EditNoteView(
        note: Note(
            id: "1",
            homeId: "home-1",
            homeItemId: nil,
            title: "Kitchen Remodel Ideas",
            body: "Consider replacing the countertops with quartz.",
            noteType: .observation,
            isPinned: true,
            authorId: "user-1",
            createdBy: "user-1",
            createdAt: "2026-01-10T10:00:00",
            updatedBy: nil,
            updatedAt: "2026-01-10T10:00:00"
        ),
        onNoteSaved: { print("Note updated") }
    )
}
