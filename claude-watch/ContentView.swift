//
//  ContentView.swift
//  claude-watch
//
//  Created by Edoardo Alberti on 19/01/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CurrentProfileView()
            .padding()
            .frame(width: 300)
    }
}

#Preview {
    ContentView()
        .environment(ProfileManager())
}
