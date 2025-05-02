//
//  MainView.swift
//  Counter App
//
//  Created by Jack Kroll on 12/21/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import SwiftUI
import CoreData

struct Count : Identifiable, Equatable{
    var date : Date
    var displayed : Bool
    var number : Int
    var step : Int
    var theme : String
    var title : String
    var id: UUID
}


struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.managedObjectContext) var moc
    @State var counts : [Count] = []
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var countsDB: FetchedResults<Database>
    
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
                        List($counts, editActions: .all) { $count in
                            ZStack{
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(Color(uiColor: UIColor.systemGray5))
                                
                                HStack{
                                    Text(count.title)
                                        .foregroundColor(colorDecider(inputColor: count.theme))
                                        .fontWeight(.semibold)
                                        .font(.title)
                                        .padding()
                                    
                                    
                                    Spacer()
                                    Text("\(count.number)")
                                        .foregroundColor(colorDecider(inputColor: count.theme))
                                        .fontWeight(.light)
                                        .font(.title)
                                        .padding()
                                    
                                }
                                
                                
                            }
                            .transition(.opacity)
                            .listRowSeparator(.hidden)
                            .transition(.opacity)
                            .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.125)
                            .onTapGesture {
                                count.date = .now
                                showCount = true
                            }
                            .swipeActions(edge: .trailing) {
                                Button{
                                    let countInDB = fetchCount(count: count, results: countsDB)
                                    if countInDB != nil{
                                        moc.delete(countInDB!)
                                        try? moc.save()
                                        withAnimation{
                                            counts.remove(object: count)
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                Button{
                                    let countInDB = fetchCount(count: count, results: countsDB)
                                    if countInDB != nil{
                                        countInDB!.number = 0
                                        try? moc.save()
                                        withAnimation {
                                            count.number = 0
                                        }
                                    }
                                    
                                } label: {
                                    Label("Recycle", systemImage: "arrow.3.trianglepath")
                                }
                                .tint(.yellow)
                                
                            }
                            
                        }
                        .safeAreaInset(edge: .bottom, content: {
                            Spacer()
                                .frame(height: 100)
                        })
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        
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
                                    withAnimation {
                                        counts.append(Count(date: count.date!, displayed: false, number: Int(count.number), step: Int(count.step), theme: count.theme!, title: count.title!, id: count.uuid!))
                                    }
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
            .onAppear{
                for countEntry in countsDB {
                    let count = Count(date: countEntry.date ?? Date.distantPast, displayed: countEntry.displayed, number: Int(countEntry.number), step: Int(countEntry.step), theme: countEntry.theme ?? "Bismuth", title: countEntry.title ?? "Untitled", id: countEntry.uuid ?? UUID())
                    counts.append(count)
                }
            }
        }
    }
}

func fetchCount(count: Count ,results: FetchedResults<Database>) -> FetchedResults<Database>.Element? {
    for countDB in results {
        if countDB.uuid == count.id {
            return countDB
        }
    }
    return nil
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
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
