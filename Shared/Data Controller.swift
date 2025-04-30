//
//  Data Controller.swift
//  Counter App
//
//  Created by Jack Kroll on 8/26/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import Foundation
import CoreData

class DataController : ObservableObject {
    let container  = NSPersistentContainer(name: "Database")
    
    init(){
        container.loadPersistentStores{description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
            
        }
    }
}
