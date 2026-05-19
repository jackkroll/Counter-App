//
//  Funni_ProjectsApp.swift
//  Shared
//
//  Created by Jack Kroll on 8/1/22.
//

import SwiftUI
import SwiftData

@main
struct Funni_ProjectsApp: App {
    @StateObject private var customizationStore = CustomizationStore()

    var body: some Scene {
        WindowGroup {
            ViewController()
                .environmentObject(customizationStore)
        }
        .modelContainer(for: Database.self)
    }
}
