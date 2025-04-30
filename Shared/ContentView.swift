import SwiftUI


struct Main: View{
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var counts: FetchedResults<Database>
    
    let themes = [
        //Light
        "Bronze": [Color.red, Color.white],
        "Platinum": [Color.blue, Color.white],
        "Gold" : [Color.yellow, Color.white],
        //Dark
        "Lead" : [Color.gray, Color.black],
        "Copper" : [Color.green, Color.black],
        "Bismuth" :[Color.pink, Color.black]
    ]
    

    
//    @AppStorage("number") var number = 0
    @State var number = 0
//    @AppStorage("step") var step = 1
    @State var step = 0
//    @AppStorage("currentTheme") var currentTheme = "Bismuth"
    @State var menuOpened = false
//    @AppStorage("title") var countTitle = "Untitled"
    @State var countTitle = "Untitled"
    
    var tapGesture: some Gesture {
        /*#-code-walkthrough(1.gestureDefinition)*/
        TapGesture()
            .onEnded {
                withAnimation {
                    counts.first?.number += Int64(counts.first?.step ?? 1)
                    try? moc.save()
                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                    impactMed.impactOccurred()
                }
            }
        /*#-code-walkthrough(1.gestureDefinition)*/
    }
    
    
    var body: some View{
        ZStack{
            themes[counts.first?.theme ?? "Bismuth"]?[1]
                .ignoresSafeArea(.all)
            VStack{
                HStack{
                    TextField("Enter Title", text: $countTitle)
                        .multilineTextAlignment(.center)
                        
                        .font(.title3)
                        .disableAutocorrection(true)
                        .foregroundColor(themes[counts.first?.theme ?? "Bismuth"]![1] == Color.black ? Color.white : Color.black)
                        .onSubmit {
                            counts.first?.title = countTitle
                            try? moc.save()
                        }.padding()
                        
            
                }
                Spacer()
                Text(String(counts.first?.number ?? 0))
                    .font(.system(size: 300))
                    .minimumScaleFactor(0.01)
                    .frame(width: .infinity,height:300)
                    .foregroundColor(themes[counts.first?.theme ?? "Bismuth"]?[0])
                Spacer()
                
                if menuOpened{
                    withAnimation{
                        PopUpMenu()
                    }
                }
                
                
                Button(action: {
                    if menuOpened == false{
                        withAnimation{
                            menuOpened = true
                        }
                    }
                    else{
                        withAnimation{
                            menuOpened = false
                        }
                    }
                    print("Menu Opened")
                    
                })
                {
                    Text("Options")
                        .fontWeight(.semibold)
                        .font(.title2)
                        .padding(20)
                        .padding(.leading,20)
                        .padding(.trailing,20)
                        .background(themes[counts.first?.theme ?? "Bismuth"]?[0])
                        .foregroundColor(themes[counts.first?.theme ?? "Bismuth"]![1] == Color.black ? Color.white : Color.black)
                        .cornerRadius(20)
                }
                    .offset(y:-15)
            }
            
        }
        .gesture(tapGesture)
        .preferredColorScheme(.dark)
            
            
        
    }
}





var tapGestureHeavy: some Gesture {
    /*#-code-walkthrough(1.gestureDefinition)*/
    TapGesture()
        .onEnded {
            let impactMed = UIImpactFeedbackGenerator(style: .heavy)
            impactMed.impactOccurred()
        }
    /*#-code-walkthrough(1.gestureDefinition)*/
}


struct PopUpMenu : View {
    var body: some View{
        
        HStack(spacing: 20){
            BottomMenu(BottomIcon: "plus.square.fill", SwitchStateMent: "pos")
            BottomMenu(BottomIcon: "minus.square.fill", SwitchStateMent: "neg")
            BottomMenu(BottomIcon: "trash", SwitchStateMent: "trash")
            ThemeMenu()
            BottomMenu(BottomIcon: "x.square.fill", SwitchStateMent: "leave")
            
            //BottomMenu(BottomIcon: "paintpalette")
    }.offset(y:-50)
        .transition(.scale)
        .gesture(tapGestureHeavy)
}
    struct ThemeMenu : View {
        
        let themes = [
            //Light
            "Bronze": [Color.red, Color.white],
            "Platinum": [Color.blue, Color.white],
            "Gold" : [Color.yellow, Color.white],
            //Dark
            "Lead" : [Color.gray, Color.black],
            "Copper" : [Color.green, Color.black],
            "Bismuth" :[Color.pink, Color.black]
        ]
        
        @Environment(\.managedObjectContext) var moc
        @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var counts: FetchedResults<Database>
        
        var body: some View{
            
            
            
        Menu{
            let availableThemes = ["Bronze", "Platinum", "Gold", "Lead", "Copper", "Bismuth"]
            ForEach(availableThemes, id: \.self){ theme in
                Button(action: {counts.first?.theme = theme; try? moc.save()}, label: {Text(theme)})
            }
        }label: {
            Image(systemName: "paintpalette.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(themes[counts.first?.theme ?? "Bismuth"]![1] == Color.black ? Color.white : Color.black)
                .padding()
        }
            
        

            
        }
    }
    
    struct BottomMenu : View{
        
        let themes = [
            //Light
            "Bronze": [Color.red, Color.white],
            "Platinum": [Color.blue, Color.white],
            "Gold" : [Color.yellow, Color.white],
            //Dark
            "Lead" : [Color.gray, Color.black],
            "Copper" : [Color.green, Color.black],
            "Bismuth" :[Color.pink, Color.black]
        ]
        
        @Environment(\.managedObjectContext) var moc
        @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var counts: FetchedResults<Database>
        
        @AppStorage("number") var number = 0
        @AppStorage("step") var step = 1
        
        @State var BottomIcon = "questionmark.circle"
        @State var SwitchStateMent = "pos"
        var body: some View{
            
            Button(action: {
                switch SwitchStateMent{
                case "pos": step = Int(1); counts.first?.step = Int16(1); try? moc.save()
                case "neg": step = Int(-1); counts.first?.step = Int16(-1); try? moc.save()
                case "trash": number = 0; counts.first?.number
                    = Int64(0); try? moc.save()
                case "leave": counts.first?.displayed = false; try? moc.save()
                    
                default: step = 1
                }
            }){
                Image(systemName: BottomIcon)
                    .resizable()
                    .scaledToFit()
                
            }.frame(width: 50, height: 50)
                .foregroundColor(themes[counts.first?.theme ?? "Bismuth"]![1] == Color.black ? Color.white : Color.black)
                
            //.background(RoundedRectangle(cornerRadius: 5))
            //.contentShape(RoundedRectangle(cornerRadius: 5))
            //.background(Color.indigo)
            
        }
        }
    }
    
struct Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}

