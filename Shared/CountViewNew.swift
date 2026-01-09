//
//  CountViewNew.swift
//  Counter App
//
//  Created by Jack Kroll on 12/23/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import SwiftUI

//pink
//green
//yellow
//noir
//blue
//red
//indigo

struct CountViewNew: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date, order: .reverse)]) var counts: FetchedResults<Database>
    
    @State var title = "Untitled"
    
    @State var number = 0
    
    @State var options = false
    
    @State var colorBar = false
    
    @State var uppersegment = false
    
    @State var step = false
        
    
    @State var stepVal = 1.0
    
    @State var themeColor = CustomColor.noir
    
    @FocusState var textFieldIsFocused : Bool
    
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader{ geo in
            ZStack{
                
                //Number
                
                
                VStack{
                    Spacer()
                    Text(String(number))
                        .frame(width: geo.size.width, height: 200)
                        .foregroundColor(themeColor)
                        .font(.system(size: 200))
                        .minimumScaleFactor(0.00001)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height * 0.8)
                .onAppear{
                    number = Int(counts.first?.number ?? 0)
                    stepVal = Double(counts.first?.step ?? 1)
                    
                    /*
                     "Bronze": [Color.red, Color.white],
                     "Platinum": [Color.blue, Color.white],
                     "Gold" : [Color.yellow, Color.white],
                     //Dark
                     "Lead" : [Color.gray, Color.black],
                     "Copper" : [Color.green, Color.black],
                     "Bismuth" :[Color.pink, Color.black]
                     */
                    switch counts.first?.theme {
                    case "Bronze":
                        themeColor = CustomColor.red
                    case "Platinum":
                        themeColor = CustomColor.blue
                    case "Gold":
                        themeColor = CustomColor.yellow
                    case "Lead":
                        themeColor = CustomColor.noir
                    case "Copper":
                        themeColor = CustomColor.green
                    case "Bismuth":
                        themeColor = CustomColor.pink
                    default:
                        themeColor = CustomColor.noir
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    counts.first?.number += Int64(counts.first?.step ?? 1)
                    impactLight.impactOccurred()
                    try? moc.save()
                    number = Int(counts.first?.number ?? 0)
                    textFieldIsFocused = false
                }
                
                //Header
                
                VStack{
                    HStack{
                        TextField("Enter a title here", text: $title)
                            .focused($textFieldIsFocused)
                            .foregroundColor(themeColor)
                            .onAppear{
                                title = counts.first?.title ?? "Unknown"
                            }
                            .padding()
                            .fontWeight(.semibold)
                            .font(.largeTitle)
                            .submitLabel(.done)
                            .minimumScaleFactor(0.5)
                            .frame(width: geo.size.width * 0.5)
                            .scrollDismissesKeyboard(.immediately)
                            .onChange(of: textFieldIsFocused) { old, new in
                                if new == false {
                                    counts.first?.title = title
                                    try? moc.save()
                                }
                            }
                        
                        Text(String(Int(stepVal)))
                            .frame(width: 75, height: 50)
                            .fontWeight(.semibold)
                            .font(.system(size: 40))
                            .minimumScaleFactor(0.1)
                            .padding()
                            .foregroundColor(themeColor)
                        
                        Spacer()
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                            .padding()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismiss()
                            }
                            .foregroundColor(themeColor)
                        Spacer()
                            
                        
                    }
                    Spacer()
                }
                
                //Footer
                
                VStack{
                    Spacer()
                    HStack{
                        //Quick undo button
                        if !options{
                            RoundedRectangle(cornerRadius: 15)
                                .overlay {
                                    Image(systemName: counts.first?.step ?? 1 > 0 ? "minus" : "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                        .frame(width: 40, height: 40)
                                        .padding(10)
                                }
                                .frame(width: 75, height: 75)
                                .padding(5)
                                .onTapGesture {
                                    withAnimation{
                                        textFieldIsFocused = false
                                        impactHeavy.impactOccurred()
                                        counts.first?.number -= Int64(counts.first?.step ?? 1)
                                        try? moc.save()
                                    }
                                    number = Int(counts.first?.number ?? 0)
                                }
                                .foregroundStyle(themeColor)
                            
                            Spacer()
                        }
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                
                            VStack{
                                if colorBar && options{
                                    HStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .padding(3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(CustomColor.red)
                                            .onTapGesture {
                                                withAnimation{
                                                    themeColor = CustomColor.red
                                                }
                                                counts.first?.theme = "Bronze"
                                                try? moc.save()
                                            }
                                            .shadow(radius: 5)
                                        RoundedRectangle(cornerRadius: 10)
                                            .padding(3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(CustomColor.yellow)
                                            .onTapGesture {
                                                withAnimation{
                                                    themeColor = CustomColor.yellow
                                                }
                                                counts.first?.theme = "Gold"
                                                try? moc.save()
                                            }
                                            .shadow(radius: 5)
                                        RoundedRectangle(cornerRadius: 10)
                                            .padding(3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(CustomColor.green)
                                            .onTapGesture {
                                                withAnimation{
                                                    themeColor = CustomColor.green
                                                }
                                                counts.first?.theme = "Copper"
                                                try? moc.save()
                                            }
                                            .shadow(radius: 5)
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .padding(3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(CustomColor.blue)
                                            .onTapGesture {
                                                withAnimation{
                                                    themeColor = CustomColor.blue
                                                }
                                                counts.first?.theme = "Platinum"
                                                try? moc.save()
                                            }
                                            .shadow(radius: 5)
                                        RoundedRectangle(cornerRadius: 10)
                                            .padding(3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(CustomColor.pink)
                                            .onTapGesture {
                                                withAnimation{
                                                    themeColor = CustomColor.pink
                                                }
                                                counts.first?.theme = "Bismuth"
                                                try? moc.save()
                                            }
                                            .shadow(radius: 5)
                                        RoundedRectangle(cornerRadius: 10)
                                            .padding(3)
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .onTapGesture {
                                                withAnimation{
                                                    themeColor = CustomColor.noir
                                                }
                                                counts.first?.theme = "Lead"
                                                try? moc.save()
                                            }
                                            .shadow(radius: 5)
                                        
                                        
                                        
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: geo.size.width * 0.9, height: 50)
                                
                                }
                                if step && options{
                                    HStack{
                                     
                                        Slider(value: $stepVal, in: -10...10)
                                            .tint(colorScheme == .dark ? .black : .white)
                                            .frame(width: geo.size.width * 0.7)
                                            .onChange(of: $stepVal.wrappedValue){ _, change in
                                                counts.first?.step = Int16(change)
                                                try? moc.save()
                                            }
                                            
                                        
                                        Text(String(Int(stepVal)))
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .fontWeight(.semibold)
                                            .font(.title2)
                                        
                                    }
                                    
                                    .foregroundColor(.white)
                                    .frame(width: geo.size.width * 0.9, height: 50)
                                }
                                HStack{
                                    if options{
                                        Image(systemName: "chevron.up.chevron.down")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(3)
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .frame(width: 40, height: 40)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation{
                                                    step.toggle()
                                                }
                                            }
                                        Spacer()
                                        Image(systemName: "trash")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(3)
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .frame(width: 40, height: 40)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                counts.first?.number = 0
                                                try? moc.save()
                                                number = Int(counts.first?.number ?? 0)
                                            }
                                        Spacer()
                                        Image(systemName: "paintpalette")
                                            .resizable()
                                            .scaledToFit()
                                        
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .frame(width: 40, height: 40)
                                            .onTapGesture {
                                                withAnimation{
                                                    colorBar.toggle()
                                                }
                                            }
                                        
                                        Spacer()
                                        
                                    }
                                    
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .scaledToFit()
                                    //.padding(3)
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                        .frame(width: 40, height: 40)
                                        .onTapGesture {
                                            print("Options Menu Opened")
                                            withAnimation{
                                                textFieldIsFocused = false
                                                options.toggle()
                                                impactHeavy.impactOccurred()
                                                colorBar = false
                                                uppersegment = false
                                                step = false
                                            }
                                        }
                                }
                                .padding()
                            }
                        }
                        .frame(width: options ? geo.size.width * 0.9 : 50, height: ((colorBar || step) && options) ? 155: 50)
                        .padding()
                        .foregroundColor(themeColor)
                    }
                }
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
            
        }
        .interactiveDismissDisabled()
        
    }
    
}


struct CustomColor {
    /*
    static let blue = Color("Blue")
    static let green = Color("Green")
    static let noir = Color("Noir")
    static let pink = Color("Pink")
    static let red = Color("Red")
    static let yellow = Color("Yellow")
     */
    static let blue = Color.blue
    static let green = Color.green
    static let noir = Color.gray
    static let pink = Color.pink
    static let red = Color.red
    static let yellow = Color.yellow
}


struct CountViewNew_Previews: PreviewProvider {
    static var previews: some View {
        CountViewNew()
    }
}
