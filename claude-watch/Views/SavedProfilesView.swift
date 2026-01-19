//
//  SavedProfilesView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct SavedProfilesView: View {
    @Environment(ProfileManager.self) private var profileManager
    @State private var expandedProfileId: UUID?
    @State private var renamingProfileId: UUID?
    @State private var newProfileName = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if profileManager.savedProfiles.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No saved profiles")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Save your current usage from the Current tab")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(profileManager.savedProfiles) { profile in
                            VStack(spacing: 0) {
                                if renamingProfileId == profile.id {
                                    VStack(spacing: 8) {
                                        TextField("Profile name", text: $newProfileName)
                                            .textFieldStyle(.roundedBorder)
                                            .focused($isTextFieldFocused)
                                            .onSubmit {
                                                renameProfile()
                                            }

                                        HStack {
                                            Button("Cancel") {
                                                renamingProfileId = nil
                                                newProfileName = ""
                                            }
                                            .buttonStyle(.borderless)

                                            Spacer()

                                            Button("Rename") {
                                                renameProfile()
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .disabled(newProfileName.isEmpty)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                } else {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ProfileRowView(
                                            profile: profile,
                                            isExpanded: expandedProfileId == profile.id
                                        ) {
                                            Task { await profileManager.refreshSavedProfile(id: profile.id) }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                if expandedProfileId == profile.id {
                                                    expandedProfileId = nil
                                                } else {
                                                    expandedProfileId = profile.id
                                                }
                                            }
                                        }

                                        if expandedProfileId == profile.id {
                                            ProfileDetailView(usageData: profile.usageData)
                                                .padding(.top, 8)
                                                .padding(.leading, 20)
                                        }
                                    }
                                    .contextMenu {
                                        Button {
                                            Task { await profileManager.refreshSavedProfile(id: profile.id) }
                                        } label: {
                                            Label("Refresh", systemImage: "arrow.clockwise")
                                        }

                                        Button {
                                            renamingProfileId = profile.id
                                            newProfileName = profile.name
                                            isTextFieldFocused = true
                                        } label: {
                                            Label("Rename", systemImage: "pencil")
                                        }

                                        Button(role: .destructive) {
                                            withAnimation {
                                                profileManager.deleteProfile(id: profile.id)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }

                                Divider()
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
    }

    private func renameProfile() {
        if let id = renamingProfileId, !newProfileName.isEmpty {
            profileManager.renameProfile(id: id, newName: newProfileName)
            renamingProfileId = nil
            newProfileName = ""
        }
    }
}
