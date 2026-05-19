//
//  CountViewNew.swift
//  Counter App
//
//  Created by Jack Kroll on 12/23/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import SwiftUI
import SwiftData
import CoreHaptics

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
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var customizationStore: CustomizationStore
    @Query(sort: \Database.date, order: .reverse) var counts: [Database]
    
    @State var title = "Untitled"
    
    @State var number = 0
    
    @State var options = false
    
    @State var colorBar = false
    
    @State var uppersegment = false
    
    @State var step = false
    
    @State var stepVal = 1.0
    @State var stepperRaw = 1.0
    
    @State var themeColor = CustomColor.noir
    @State var showCustomization = false
    
    @FocusState var textFieldIsFocused : Bool
    @State var hapticEngine: CHHapticEngine? = try? .init()
    
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
            ZStack{
                
                //Number
                
                VStack{
                    Spacer()
                    Text(number.formatted(.number))
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .foregroundColor(themeColor)
                        .font(.system(size: 200, weight: counts.first?.fontWeight, design: counts.first?.fontDesign))
                        .minimumScaleFactor(0.00001)
                        .contentTransition(.numericText())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear{
                    number = Int(counts.first?.number ?? 0)
                    stepVal = Double(counts.first?.step ?? 1)
                    // If it is outside stepper range, adjust to prevent crash
                    if !(-10...9).contains(stepVal) {
                        stepVal = 1.0
                    }
                    stepperRaw = stepVal
                    prepareHaptics()
                    
                    /*
                     "Bronze": [Color.red, Color.white],
                     "Platinum": [Color.blue, Color.white],
                     "Gold" : [Color.yellow, Color.white],
                     //Dark
                     "Lead" : [Color.gray, Color.black],
                     "Copper" : [Color.green, Color.black],
                     "Bismuth" :[Color.pink, Color.black]
                     */
                    syncCustomizationState()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    counts.first?.number += Int64(counts.first?.step ?? 1)
                    playCountHaptic()
                    try? modelContext.save()
                    withAnimation {
                        number = Int(counts.first?.number ?? 0)
                    }
                    textFieldIsFocused = false
                }
                
                //Header
                
                VStack{
                    HStack {
                        TextField("Enter a title here", text: $title)
                            .focused($textFieldIsFocused)
                            .foregroundColor(themeColor)
                            .onAppear{
                                title = counts.first?.title ?? "Unknown"
                            }
                            .padding()
                            .fontWeight(counts.first?.fontWeight)
                            .fontDesign(counts.first?.fontDesign)
                            .font(.largeTitle)
                            .submitLabel(.done)
                            .minimumScaleFactor(0.5)
                            .scrollDismissesKeyboard(.immediately)
                            .onChange(of: textFieldIsFocused) { old, new in
                                if new == false {
                                    counts.first?.title = title
                                    try? modelContext.save()
                                }
                            }
                        
                        Text(String(Int(stepVal)))
                            .fontWeight(.semibold)
                            .font(.system(size: 40))
                            .minimumScaleFactor(0.1)
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
                                        try? modelContext.save()
                                        number = Int(counts.first?.number ?? 0)
                                    }
                                }
                                .foregroundStyle(themeColor)
                            
                            Spacer()
                        }
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                
                            VStack{
                                if options {
                                    HStack {
                                        Button {
                                            openCustomization()
                                        } label: {
                                            HStack {
                                                Image(systemName: customizationStore.hasCustomizationPack ? "textformat" : "lock")
                                                Text("Customization+")
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical)
                                            .background(.thickMaterial)
                                            .clipShape(Capsule())
                                        }
                                    
                                        
                                    }
                                    
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                }
                                if colorBar && options{
                                    VStack {
                                        
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
                                                    counts.first?.customColorHex = nil
                                                    try? modelContext.save()
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
                                                    counts.first?.customColorHex = nil
                                                    try? modelContext.save()
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
                                                    counts.first?.customColorHex = nil
                                                    try? modelContext.save()
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
                                                    counts.first?.customColorHex = nil
                                                    try? modelContext.save()
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
                                                    counts.first?.customColorHex = nil
                                                    try? modelContext.save()
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
                                                    counts.first?.customColorHex = nil
                                                    try? modelContext.save()
                                                }
                                                .shadow(radius: 5)
                                            
                                            
                                            
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, maxHeight: 150)
                                
                                }
                                if step && options{
                                    HStack{
                                        Slider(value: $stepperRaw, in: -10...9, step: 1)
                                            .tint(colorScheme == .dark ? .black : .white)
                                            .frame(maxWidth: .infinity)
                                            .onChange(of: stepperRaw){ _, change in
                                                var adjustedChange = change
                                                if adjustedChange >= 0 {
                                                    adjustedChange += 1
                                                }
                                                stepVal = adjustedChange
                                                counts.first?.step = Int16(adjustedChange)
                                                try? modelContext.save()
                                            }
                                            
                                        
                                        Text(String(Int(stepVal)))
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                            .fontWeight(.semibold)
                                            .font(.title2)
                                        
                                    }
                                    
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .padding()
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
                                                    if colorBar {
                                                        colorBar = false
                                                    }
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
                                                try? modelContext.save()
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
                                                    if step {
                                                        step = false
                                                    }
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
                                        .contentShape(Rectangle())
                                }
                                .padding()
                            }
                        }
                        .foregroundStyle(themeColor)
                        .frame(maxWidth: options ? .infinity : 50, maxHeight: options ? 155 : 50)
                        //.contentShape(Rectangle())
                        .padding()
                        
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .interactiveDismissDisabled()
            .sheet(isPresented: $showCustomization) {
                if let count = counts.first {
                    if customizationStore.hasCustomizationPack {
                        FontEditor(count: count)
                            .onDisappear {
                                syncCustomizationState()
                            }
                    } else {
                        UpsellView()
                    }
                }
            }

        }

    private func syncCustomizationState() {
        guard let count = counts.first else {
            themeColor = CustomColor.noir
            return
        }

        themeColor = colorDecider(inputColor: count.theme, customColorHex: count.customColorHex)
    }

    private func openCustomization() {
        showCustomization = true
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Error creating the haptic engine: \(error.localizedDescription)")
        }
    }

    private func playCountHaptic() {
        guard let count = counts.first else {
            impactLight.impactOccurred()
            return
        }

        let hapticStyle: CounterHapticStyle
        if let rawValue = count.hapticStyleRawValue, let savedStyle = CounterHapticStyle(rawValue: rawValue) {
            hapticStyle = savedStyle
        } else if count.hapticDuration == nil && count.hapticIntensity == nil && count.hapticSharpness == nil {
            hapticStyle = .light
        } else {
            hapticStyle = .custom
        }

        if let impactStyle = hapticStyle.impactStyle {
            UIImpactFeedbackGenerator(style: impactStyle).impactOccurred()
            return
        }

        guard
            let duration = count.hapticDuration,
            let intensity = count.hapticIntensity,
            let sharpness = count.hapticSharpness
        else {
            impactLight.impactOccurred()
            return
        }

        guard duration > 0 else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            impactLight.impactOccurred()
            return
        }

        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity)),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness))
                ],
                relativeTime: 0,
                duration: duration
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            impactLight.impactOccurred()
            print("Failed to play custom haptic: \(error.localizedDescription)")
        }
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
            .modelContainer(PreviewDatabase.container())
            .environmentObject(CustomizationStore(loadFromStore: false, hasCustomizationPack: true))
    }
}
