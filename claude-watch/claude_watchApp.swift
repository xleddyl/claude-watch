//
//  claude_watchApp.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

@main
struct claude_watchApp: App {
    @State private var profileManager = ProfileManager()

    var body: some Scene {
        MenuBarExtra("Claude Watch", systemImage: "gauge") {
            ContentView()
                .environment(profileManager)
        }
        .menuBarExtraStyle(.window)
    }
}
