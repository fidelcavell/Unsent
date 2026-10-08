//
//  JournalListView.swift
//  Postbox
//
//  Created by habil on 09/08/26.
//

import SwiftUI

struct JournalListView: View {
    @Environment(\.appFactory) private var appFactory
    @AppStorage("hasSeenWelcomeCanvas") private var hasSeenWelcomeCanvas: Bool = false
    @State private var showWelcome: Bool = false

    // Owned here, injected into the environment for all children
    @State private var viewModel: JournalViewModel?

    var body: some View {
        ZStack {
            Group {
                if let viewModel {
                    // Your real list UI goes here.
                    // Any child in this subtree can read JournalViewModel
                    // using @Environment(JournalViewModel.self)
                    JournalEditorView()
                }
            }
            .environment(viewModel)   // ← broadcasts the VM to the whole subtree
            
            if showWelcome {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showWelcome = false
                            hasSeenWelcomeCanvas = true
                        }
                    }
                
                WelcomeCanvasView()
            }
        }
        .onAppear {
            guard viewModel == nil else { return }
            viewModel = appFactory?.makeJournalViewModel()
            
            if !hasSeenWelcomeCanvas {
                showWelcome = true
            }
        }
    }
}
