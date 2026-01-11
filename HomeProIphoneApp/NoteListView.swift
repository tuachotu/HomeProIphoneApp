//
//  NoteListView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 1/10/26.
//

import SwiftUI
import FirebaseAuth

struct NoteListView: View {
    let homeId: String?
    let homeItemId: String?

    @State private var notes: [Note] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAddNote = false
    @State private var editingNote: Note?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Notes")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Button(action: { showingAddNote = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add Note")
                    }
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)

            Divider()

            // Content
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if notes.isEmpty {
                emptyStateView
            } else {
                notesScrollView
            }
        }
        .onAppear {
            Task {
                await fetchNotes()
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(
                homeId: homeId,
                homeItemId: homeItemId,
                onNoteSaved: {
                    showingAddNote = false
                    Task {
                        await fetchNotes()
                    }
                }
            )
        }
        .sheet(item: $editingNote) { note in
            EditNoteView(
                note: note,
                onNoteSaved: {
                    editingNote = nil
                    Task {
                        await fetchNotes()
                    }
                }
            )
        }
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading notes...")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(DesignSystem.Colors.error)

            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task {
                    await fetchNotes()
                }
            }
            .secondaryButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "note.text")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Text("No notes yet")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            Text("Add your first note to get started")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Button("Add Note") {
                showingAddNote = true
            }
            .primaryButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var notesScrollView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Pinned notes section
                if pinnedNotes.count > 0 {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("PINNED")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .padding(.horizontal, DesignSystem.Spacing.md)

                        ForEach(pinnedNotes) { note in
                            NoteCardView(
                                note: note,
                                onEdit: { editingNote = note },
                                onTogglePin: { Task { await togglePin(note: note) } },
                                onDelete: { Task { await deleteNote(note: note) } }
                            )
                        }
                    }
                }

                // Regular notes section
                if unpinnedNotes.count > 0 {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        if pinnedNotes.count > 0 {
                            Text("NOTES")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                        }

                        ForEach(unpinnedNotes) { note in
                            NoteCardView(
                                note: note,
                                onEdit: { editingNote = note },
                                onTogglePin: { Task { await togglePin(note: note) } },
                                onDelete: { Task { await deleteNote(note: note) } }
                            )
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    private var pinnedNotes: [Note] {
        notes.filter { $0.isPinned }
    }

    private var unpinnedNotes: [Note] {
        notes.filter { !$0.isPinned }
    }

    private func fetchNotes() async {
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
            let fetchedNotes = try await APIService.shared.getNotes(
                homeId: homeId,
                homeItemId: homeItemId,
                firebaseToken: firebaseToken
            )

            await MainActor.run {
                notes = fetchedNotes
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to load notes: \(error.localizedDescription)"
            }
        }
    }

    private func togglePin(note: Note) async {
        guard let user = Auth.auth().currentUser else { return }

        do {
            let firebaseToken = try await user.getIDToken()

            let updatedNote: Note
            if note.isPinned {
                updatedNote = try await APIService.shared.unpinNote(
                    noteId: note.id,
                    firebaseToken: firebaseToken
                )
            } else {
                updatedNote = try await APIService.shared.pinNote(
                    noteId: note.id,
                    firebaseToken: firebaseToken
                )
            }

            // Optimistically update the UI
            await MainActor.run {
                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                    notes[index] = updatedNote
                }
            }
        } catch {
            print("❌ Failed to toggle pin: \(error.localizedDescription)")
            // Show error to user
            await MainActor.run {
                errorMessage = "Failed to update pin status"
            }
        }
    }

    private func deleteNote(note: Note) async {
        guard let user = Auth.auth().currentUser else { return }

        do {
            let firebaseToken = try await user.getIDToken()
            try await APIService.shared.deleteNote(
                noteId: note.id,
                firebaseToken: firebaseToken
            )

            // Remove from local list
            await MainActor.run {
                notes.removeAll { $0.id == note.id }
            }
        } catch {
            print("❌ Failed to delete note: \(error.localizedDescription)")
            // Show error to user
            await MainActor.run {
                errorMessage = "Failed to delete note"
            }
        }
    }
}

#Preview {
    NoteListView(homeId: "home-1", homeItemId: nil)
        .background(DesignSystem.Colors.background)
}
