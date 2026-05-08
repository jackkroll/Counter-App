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
    var body: some Scene {
        WindowGroup {
            ViewController()
        }
        .modelContainer(for: Database.self)
    }
}
