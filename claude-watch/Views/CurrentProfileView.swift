//
//  CurrentProfileView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct CurrentProfileView: View {
    @Environment(ProfileManager.self) private var profileManager
    @State private var isEditingName = false
    @State private var profileName = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Usage")
                    .font(.headline)
                Spacer()
                Button {
                    Task {
                        await profileManager.fetchCurrentUsage()
                    }
                } label: {
                    Image(systemName: profileManager.isRefreshing ? "arrow.trianglehead.2.clockwise" : "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .disabled(profileManager.isInitialLoading || profileManager.isRefreshing)
            }

            ProfileDetailView(usageData: profileManager.currentUsageData ?? .placeholder)

            if let errorMessage = profileManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if profileManager.currentUsageData != nil {
                if isEditingName {
                    VStack(spacing: 8) {
                        TextField("Profile name", text: $profileName)
                            .textFieldStyle(.roundedBorder)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                saveProfile()
                            }

                        HStack {
                            Button("Cancel") {
                                isEditingName = false
                                profileName = ""
                            }
                            .buttonStyle(.borderless)

                            Spacer()

                            Button("Save") {
                                saveProfile()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(profileName.isEmpty)
                        }
                    }
                } else {
                    Button("Save Profile") {
                        profileName = ""
                        isEditingName = true
                        isTextFieldFocused = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            Task {
                await profileManager.fetchCurrentUsage()
            }
        }
    }

    private func saveProfile() {
        if !profileName.isEmpty {
            profileManager.saveCurrentProfile(name: profileName)
            isEditingName = false
            profileName = ""
        }
    }
}
