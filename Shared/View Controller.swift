//
//  View Controller.swift
//  Counter App
//
//  Created by Jack Kroll on 8/26/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import Foundation
import SwiftUI

struct ViewController: View{
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var counts: FetchedResults<Database>

var body: some View {
    //sswitch to make count view the default
    /*
    if counts.count == 0 || counts.first?.displayed == false {
     CountView()
    }
    else{
        Main(number: Int(counts.first?.number ?? 0), step: Int(counts.first?.step ?? 0), countTitle: counts.first?.title ?? "Untitled")
    }
     */
    
    MainView()
    
}
}
