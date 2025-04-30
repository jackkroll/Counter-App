//
//  CountView.swift
//  Counter App
//
//  Created by Jack Kroll on 8/13/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct CountView : View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let themes = [
        //Light
        "Bronze":[Color.red,Color.white],
        "Platinum":[Color.blue,Color.white],
        "Gold":[Color.yellow,Color.white],
        //Dark
        "Lead":[Color.gray, Color.black],
        "Copper":[Color.green,Color.black],
        "Bismuth":[Color.pink,Color.black]
    ]
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var counts: FetchedResults<Database
>
    
    var body: some View{
        ScrollView{
            LazyVStack{
                ForEach(counts){count in
                    HStack{
                        Button(action: {count.date = Date()
                               count.displayed = true
                            try? moc.save()}){
                            
                        Text(count.title ?? "Unknown")
                            .fontWeight(.bold)
                            .font(.system(size: 30))
                            .minimumScaleFactor(0.01)
                            .padding()
                        
                        Spacer()
                                
                        Text(String(count.number))
                            .fontWeight(.thin)
                            .font(.system(size: 30))
                            .minimumScaleFactor(0.01)
                            .padding()
                        

                            }
                        
                    }.contextMenu(
                        ContextMenu{
                        Button{
                            moc.delete(count)
                            try? moc.save()
                        } label: {
                            Label("Delete", systemImage: "x")
                        }
                        }
                    )
                    .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [themes[count.theme ?? "Bismuth"]![0], themes[count.theme ?? "Bismuth"]![1]]), startPoint:.topLeading, endPoint: .bottomTrailing))
                    .background(in: RoundedRectangle(cornerRadius: 20))
                    .foregroundColor(themes[count.theme ?? "Bismuth"]![1] == Color.black ? Color.white : Color.black)
                        .padding(.leading)
                        .padding(.trailing)

                }
            }
        }
                Spacer()
                //Divider()
                HStack{
                    
                    Button("Add"){
                        let count = Database(context: moc)
                        count.number = Int64(0)
                        count.step = 1
                        count.title = "Untitled"
                        count.theme = colorScheme == .dark ? ["Lead", "Copper", "Bismuth"].randomElement()! : ["Bronze", "Platinum", "Gold"].randomElement()!
                        count.date = Date()
                        count.uuid = UUID()
                        try? moc.save()
                    }.foregroundColor(.blue)
                    .padding()
                    Spacer()
                    Button("Delete All"){
                        for count in counts{
                            moc.delete(count)
                            try? moc.save()
                        }
                    }.foregroundColor(.red)
                        .padding()
                }
        
        
    }
    
}


struct Previews2: PreviewProvider {
    static var previews: some View {
        CountView()
    }
}
