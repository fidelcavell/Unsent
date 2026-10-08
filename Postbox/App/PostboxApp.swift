//
//  PostboxApp.swift
//  Postbox
//
//  Created by habil on 09/08/26.
//

import SwiftData
import SwiftUI

@main
struct PostboxApp: App {
    let container: ModelContainer
    
    init() {
        let schema = Schema([
            Journal.self,
        ])
        
        do {
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.appFactory, AppFactory(modelContext: container.mainContext))
        }
        .modelContainer(container)
    }
}
