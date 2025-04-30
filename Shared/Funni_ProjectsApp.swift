//
//  Funni_ProjectsApp.swift
//  Shared
//
//  Created by Jack Kroll on 8/1/22.
//

import SwiftUI

@main
struct Funni_ProjectsApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ViewController()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
