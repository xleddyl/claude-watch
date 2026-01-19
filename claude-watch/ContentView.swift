//
//  ContentView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

enum Tab {
    case current
    case saved
}

struct ContentView: View {
    @State private var selectedTab: Tab = .current

    var body: some View {
        VStack(spacing: 16) {
            Picker("", selection: $selectedTab) {
                Text("Current").tag(Tab.current)
                Text("Saved").tag(Tab.saved)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            switch selectedTab {
            case .current:
                CurrentProfileView()
            case .saved:
                SavedProfilesView()
            }
        }
        .padding()
        .frame(width: 300)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

#Preview {
    ContentView()
        .environment(ProfileManager())
}
