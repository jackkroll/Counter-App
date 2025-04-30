//
//  MainView.swift
//  Counter App
//
//  Created by Jack Kroll on 12/21/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var counts: FetchedResults<Database>
    
    @State var showCount = false
    @State var showReview = false
    
    @AppStorage("updatelog") var updateLog: String = ""
    @AppStorage("countsClosed") var closed: Int = 1
    
    @AppStorage("neverShowReview") var reviewMute: Bool = false
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @State var displayUpdateLog = false
    
    var body: some View {
        GeometryReader{ geo in
            ZStack{
                VStack{
                    HStack{
                        Text("Current Counts")
                            .padding()
                            .fontWeight(.semibold)
                            .font(.largeTitle)
                        Spacer()
                    }
                    if counts.count > 0{
                        ScrollView{
                            ForEach(counts) {count in
                                ZStack{
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(Color(uiColor: UIColor.systemGray5))
                                    
                                    HStack{
                                        Text(count.title ?? "Unknown")
                                            .foregroundColor(colorDecider(inputColor: count.theme ?? "Bismuth"))
                                            .fontWeight(.semibold)
                                            .font(.title)
                                            .padding()
                                        
                                        
                                        Spacer()
                                        Text("\(count.number)")
                                            .foregroundColor(colorDecider(inputColor: count.theme ?? "Bismuth"))
                                            .fontWeight(.light)
                                            .font(.title)
                                            .padding()
                                        
                                    }
                                    
                                    
                                }
                                
                                .transition(.opacity)
                                .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.125)
                                .onTapGesture {
                                    count.date = .now
                                    showCount = true
                                }
                                .contextMenu {
                                    Button(role: .destructive){
                                        withAnimation{
                                            moc.delete(count)
                                            try? moc.save()
                                        }
                                    } label: {
                                        Label("Delete Count", systemImage: "trash")
                                    }
                                }
                                
                                
                                
                                //.padding()
                                
                            }
                        }
                        .sheet(isPresented: $showCount){
                            CountViewNew()
                                .onDisappear{
                                    closed += 1
                                    if closed % 11 == 0 && closed != 0 && !reviewMute{
                                        showReview = true
                                        
                                    }
                                    else{
                                        print(closed)
                                    }
                                }
                        }
                        .sheet(isPresented: $showReview){
                            ReviewApp()
                                .presentationDetents([.fraction(1/3)])
                                .onDisappear{
                                    closed += 1
                                }
                                
                        }
                    }
                    else{
                        Text("You don't have any current counts, add one below")
                            .padding()
                            .font(.title2)
                    }
                }
                VStack{
                    Spacer()
                    //Bottom Menu
                    
                    HStack{
                        if counts.count > 0{
                            Spacer()
                        }
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: counts.count > 0 ? 70 : geo.size.width - 50, height: 70)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .overlay{
                                Image(systemName: "plus")
                                    .resizable()
                                    .padding()
                                    .scaledToFit()
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                
                            }
                            .onTapGesture {
                                withAnimation{
                                    let count = Database(context: moc)
                                    count.number = Int64(0)
                                    count.step = 1
                                    count.title = "Untitled"
                                    count.theme = ["Lead", "Copper", "Bismuth", "Bronze", "Platinum", "Gold"].randomElement()!
                                    count.date = Date()
                                    count.uuid = UUID()
                                    try? moc.save()
                                }
                            }
                    }
                }
                .onAppear{
                    if updateLog != appVersion{
                        displayUpdateLog = true
                        updateLog = appVersion ?? "1.20"
                    }
                    
                }
                .padding()
                .sheet(isPresented: $displayUpdateLog){
                    UpdateLog()
                }
                
            }
        }
    }
}

func colorDecider(inputColor : String) -> Color {
    switch inputColor {
    case "Bronze":
        return CustomColor.red
    case "Platinum":
        return CustomColor.blue
    case "Gold":
        return CustomColor.yellow
    case "Lead":
        return CustomColor.noir
    case "Copper":
        return CustomColor.green
    case "Bismuth":
        return CustomColor.pink
    default:
        return CustomColor.noir
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
