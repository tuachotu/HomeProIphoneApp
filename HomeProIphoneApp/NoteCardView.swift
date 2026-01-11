//
//  NoteCardView.swift
//  HomeProIphoneApp
//
//  Created by Claude Code on 1/10/26.
//

import SwiftUI

struct NoteCardView: View {
    let note: Note
    let onEdit: () -> Void
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header with note type and pin indicator
            HStack(alignment: .top) {
                // Note type badge
                HStack(spacing: 4) {
                    Image(systemName: note.noteType.iconName)
                        .font(.system(size: 12))
                    Text(note.noteType.displayName)
                        .font(DesignSystem.Typography.caption2)
                }
                .foregroundColor(noteTypeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(noteTypeColor.opacity(0.15))
                .cornerRadius(4)

                Spacer()

                // Pin indicator
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.accent)
                }
            }

            // Title (if present)
            if let title = note.title, !title.isEmpty {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }

            // Body
            Text(note.body)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(5)

            // Actions
            HStack(spacing: DesignSystem.Spacing.md) {
                // Edit button
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                }

                // Pin/Unpin button
                Button(action: onTogglePin) {
                    HStack(spacing: 4) {
                        Image(systemName: note.isPinned ? "pin.slash" : "pin")
                        Text(note.isPinned ? "Unpin" : "Pin")
                    }
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                }

                Spacer()

                // Delete button
                Button(action: { showDeleteConfirmation = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.error)
                }
            }
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
        .alert("Delete Note", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }

    private var noteTypeColor: Color {
        switch note.noteType {
        case .general:
            return Color.gray
        case .observation:
            return DesignSystem.Colors.primary
        case .todo:
            return Color.orange
        case .question:
            return Color.purple
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        // Pinned observation note with title
        NoteCardView(
            note: Note(
                id: "1",
                homeId: "home-1",
                homeItemId: nil,
                title: "Kitchen Remodel Ideas",
                body: "Consider replacing the countertops with quartz. The current laminate is showing wear and tear.",
                noteType: .observation,
                isPinned: true,
                authorId: "user-1",
                createdBy: "user-1",
                createdAt: "2026-01-10T10:00:00",
                updatedBy: nil,
                updatedAt: "2026-01-10T10:00:00"
            ),
            onEdit: { print("Edit tapped") },
            onTogglePin: { print("Toggle pin tapped") },
            onDelete: { print("Delete tapped") }
        )

        // Todo note without title
        NoteCardView(
            note: Note(
                id: "2",
                homeId: nil,
                homeItemId: "item-1",
                title: nil,
                body: "Replace HVAC filter - buy 16x20x1 MERV 11",
                noteType: .todo,
                isPinned: false,
                authorId: "user-1",
                createdBy: "user-1",
                createdAt: "2026-01-10T11:00:00",
                updatedBy: nil,
                updatedAt: "2026-01-10T11:00:00"
            ),
            onEdit: { print("Edit tapped") },
            onTogglePin: { print("Toggle pin tapped") },
            onDelete: { print("Delete tapped") }
        )

        // Question note
        NoteCardView(
            note: Note(
                id: "3",
                homeId: nil,
                homeItemId: "item-2",
                title: "Water Heater Replacement",
                body: "Should we repair or replace this water heater? It's 12 years old and making strange noises.",
                noteType: .question,
                isPinned: false,
                authorId: "user-1",
                createdBy: "user-1",
                createdAt: "2026-01-10T12:00:00",
                updatedBy: nil,
                updatedAt: "2026-01-10T12:00:00"
            ),
            onEdit: { print("Edit tapped") },
            onTogglePin: { print("Toggle pin tapped") },
            onDelete: { print("Delete tapped") }
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}
