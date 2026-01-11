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
    @State var showAdd = false
    @State var searchText: String = ""
    
    @AppStorage("updatelog") var updateLog: String = ""
    @AppStorage("countsClosed") var closed: Int = 1
    
    @AppStorage("neverShowReview") var reviewMute: Bool = false
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @State var displayUpdateLog = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if counts.count > 0 || !searchText.isEmpty {
                    if counts.isEmpty {
                        ContentUnavailableView {
                            Label(LocalizedStringKey("No Results"), systemImage: "magnifyingglass")
                        } description: {
                            Text(LocalizedStringKey("Try searching for something different"))
                        }
                    }
                    List {
                        ForEach($counts) { $count in
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
                                        .contentTransition(.numericText())
                                    
                                }
                                .padding()
                                .background(Color(uiColor: UIColor.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                            .transition(.opacity)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .transition(.opacity)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                let countInDB = fetchCount(count: count, results: countsDB)
                                if countInDB != nil {
                                    countInDB!.date = .now
                                    try? moc.save()
                                    showCount = true
                                }
                            }
                            
                            .swipeActions(edge: .trailing) {
                                Button{
                                    
                                    if let countInDB = fetchCount(count: count, results: countsDB) {
                                        moc.delete(countInDB)
                                        try? moc.save()
                                        withAnimation{
                                            counts.remove(object: count)
                                        }
                                    }
                                    
                                } label: {
                                    Label(LocalizedStringKey("Delete"), systemImage: "trash")
                                }
                                .tint(.red)
                                
                                Button{
                                    if let countInDB = fetchCount(count: count, results: countsDB){
                                        countInDB.number = 0
                                        try? moc.save()
                                        withAnimation {
                                            count.number = 0
                                        }
                                    }
                                    
                                } label: {
                                    Label(LocalizedStringKey("Recycle"), systemImage: "arrow.3.trianglepath")
                                        .bold()
                                }
                                .tint(.yellow)
                                
                            }
                            
                            
                        }
                        .onMove(perform: moveCounts)
                        .moveDisabled(!searchText.isEmpty)
                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onChange(of: counts) { _, newValue in
                        if searchText.isEmpty {
                            let defaults = UserDefaults.standard
                            var organized : [String] = []
                            for count in newValue {
                                organized.append(count.id.uuidString)
                            }
                            defaults.set(organized, forKey: "OrganizedCounts")
                        }
                    }
                    .onChange(of: showCount) { _, newValue in
                        counts = loadCounts(db: countsDB)
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
                    ContentUnavailableView {
                        Label(LocalizedStringKey("No Saved Counts"), systemImage: "rectangle.portrait.on.rectangle.portrait.fill")
                    } description: {
                        Text(LocalizedStringKey("Create a count by adding one below"))
                    }
                }
            }
            .onChange(of: searchText) {
                let allCounts = loadCounts(db: countsDB)
                if searchText.isEmpty {
                    withAnimation {
                        counts = allCounts
                    }
                }
                else {
                    withAnimation {
                        counts = allCounts.filter({$0.title.localizedCaseInsensitiveContains(searchText)})
                    }
                }
                
            }
            .navigationDestination(isPresented: $showCount, destination: {
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
                    .navigationBarBackButtonHidden(true)
            })
            .sheet(isPresented: $showAdd) {
                AddCountSheet(showSheet: $showCount)
                    .presentationDetents([.fraction(1/3)])
            }
            .navigationTitle(LocalizedStringKey("Current Counts"))
            .safeAreaInset(edge: .bottom) {
                HStack {
                    if counts.count > 0 || !searchText.isEmpty {
                        Spacer()
                    }
                    Button {
                        withAnimation {
                            showAdd = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .padding()
                            .scaledToFit()
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(maxWidth: counts.count > 0 || !searchText.isEmpty ? 70 : .infinity, maxHeight: 70)
                    }
                    .background(colorScheme == .dark ? .white : .black)
                    .modifier {
                        if #available(iOS 26, *) {
                            $0.clipShape(ConcentricRectangle(corners: .concentric(minimum: 12), isUniform: true))
                        } else {
                            $0.clipShape(Capsule())
                        }
                    }
                    .padding(10)
                    /*
                     RoundedRectangle(cornerRadius: 15)
                     .frame(maxWidth: counts.count > 0 ? 70 : .infinity, maxHeight: 70)
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
                     */
                }
                .ignoresSafeArea(.all)
            }
            .onAppear{
                counts = loadCounts(db: countsDB)
                
                if updateLog != appVersion{
                    displayUpdateLog = true
                    updateLog = appVersion ?? "1.20"
                }
                
            }
            .sheet(isPresented: $displayUpdateLog){
                UpdateLog()
            }
            .searchToolbarIfAvailable()
        }
        
    }
    
    private func moveCounts(from source: IndexSet, to destination: Int) {
        counts.move(fromOffsets: source, toOffset: destination)
        if searchText.isEmpty {
            let defaults = UserDefaults.standard
            let organized = counts.map { $0.id.uuidString }
            defaults.set(organized, forKey: "OrganizedCounts")
        }
    }
}

func loadCounts(db: FetchedResults<Database>) -> [Count] {
    let defaults = UserDefaults.standard
    var organized = defaults.object(forKey:"OrganizedCounts") as? [String] ?? []
    
    var counts : [Count] = []
    for countEntry in db {
        let count = Count(date: countEntry.date ?? Date.distantPast, displayed: countEntry.displayed, number: Int(countEntry.number), step: Int(countEntry.step), theme: countEntry.theme ?? "Bismuth", title: countEntry.title ?? "Untitled", id: countEntry.uuid ?? UUID())
        counts.append(count)
    }
    
    for count in counts {
        if !(organized.contains(count.id.uuidString)) {
            organized.append(count.id.uuidString)
        }
    }
    var output : [Count] = []
    
    for uuid in organized {
        let count = counts.first(where: {$0.id.uuidString == uuid})
        if count != nil {
            output.append(count!)
        }
        //if the uuid is stored, but no longer exists as a count in DB
        else {
            organized.remove(object: uuid)
        }
    }
    defaults.set(organized, forKey: "OrganizedCounts")
    return output
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
public extension View {
    /// Modify a view with a `ViewBuilder` closure.
    ///
    /// This represents a streamlining of the
    /// [`modifier`](https://developer.apple.com/documentation/swiftui/view/modifier(_:))
    /// \+ [`ViewModifier`](https://developer.apple.com/documentation/swiftui/viewmodifier)
    /// pattern.
    /// - Note: Useful only when you don't need to reuse the closure.
    /// If you do, turn the closure into an extension! ♻️
    func modifier<ModifiedContent: View>(
        @ViewBuilder body: (_ content: Self) -> ModifiedContent
    ) -> ModifiedContent {
        body(self)
    }
}

extension View {
    @ViewBuilder
    func searchToolbarIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.toolbar{
                DefaultToolbarItem(kind: .search, placement: .topBarTrailing)
            }
        } else {
            self
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

#Preview("Empty State") {
    MainView()
}
#Preview("With Test Data") {
    let counts = [
        Count(date: .now, displayed: true, number: 42, step: 1, theme: "Gold", title: "Gold Counter", id: UUID()),
        Count(date: .now, displayed: true, number: 17, step: 2, theme: "Platinum", title: "Platinum Steps", id: UUID()),
        Count(date: .now, displayed: true, number: 8, step: 1, theme: "Bronze", title: "Bronze Medal", id: UUID())
    ]
    MainView(counts: counts)
}

