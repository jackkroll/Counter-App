//
//  FontEditor.swift
//  Counter App (iOS)
//
//  Created by Jack Kroll on 5/8/26.
//  Copyright © 2026 JackKroll. All rights reserved.
//

import SwiftUI
import CoreHaptics

struct FontEditor: View {
    @State private var exampleCount: Int = 20
    @State var engine: CHHapticEngine? = try? .init()
    @Binding var count: Database
    let weights : [Font.Weight] = [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]
    let designs : [Font.Design] = [.default, .monospaced, .rounded, .serif]
    @State private var selectedDesign: Font.Design = .default
    @State private var weightIndexDouble: Double = 4
    @State private var selectedColor: Color = .green
    @State private var hapticIntensity: CGFloat = 0.5
    @State private var hapticSharpness: CGFloat = 0.5
    @State private var hapticDuration: CGFloat = 0.1
    @State private var selectedField: HapticField = .duration
    
    enum HapticField: String, CaseIterable, Hashable {
        case duration, sharpness, intensity
        var description: String { rawValue.capitalized }
    }
    
    private var weightIndex: Int { Int(weightIndexDouble.rounded()) }
    var body: some View {
        VStack {
            Spacer()
            Text(exampleCount.formatted(.number))
                .font(.system(size: 200, weight: weights[weightIndex], design: selectedDesign))
                .minimumScaleFactor(0.0001)
                .foregroundStyle(selectedColor)
                .contentTransition(.numericText())
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                exampleCount += 1
                dynamicHaptic(haptics: haptics)
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Text("Example Count Title")
                    .fontWeight(weights[weightIndex])
                    .fontDesign(selectedDesign)
                    .foregroundStyle(selectedColor)
                Spacer()
            }
            .padding()
        }
        .animation(.default, value: selectedDesign)
        .safeAreaInset(edge: .bottom) {
            Form {
                Section {
                    VStack(alignment: .leading){
                        Text("Font Weight")
                            .font(.callout)
                        Slider(value: $weightIndexDouble, in: 0...Double(max(0, weights.count - 1)), step: 1)
                    }
                    
                    Picker("Font Design",selection: $selectedDesign) {
                        ForEach(designs, id:\.hashValue) { design in
                            Text(designName(design))
                                .tag(design)
                                .fontDesign(design)
                        }
                    }
                } header: {
                    Text("Font")
                }
                Section {
                    ColorPicker("Counter Color", selection: $selectedColor, supportsOpacity: false)
                } header: {
                    Text("Color")
                }
                
                Section {
                    Picker("", selection: $selectedField) {
                        ForEach(HapticField.allCases, id: \.self) { hapticField in
                            Text(hapticField.description)
                                .tag(hapticField)
                        }
                    }
                    .pickerStyle(.segmented)
                    switch selectedField {
                    case .duration:
                        VStack(alignment: .leading){
                            Slider(value: $hapticDuration, in: 0...0.5) {
                                Text("Duration")
                            } minimumValueLabel: {
                                Text("0 (off)")
                            } maximumValueLabel: {
                                Text("1/2s")
                            }
                        }
                    case .sharpness:
                        VStack(alignment: .leading){
                            Slider(value: $hapticSharpness, in: 0...1)
                        }
                    case .intensity:
                        VStack(alignment: .leading){
                            Slider(value: $hapticIntensity, in: 0...1)
                        }
                    }
                    
                    
                    VStack(alignment: .leading){
                        Button("Play Haptics") {
                            dynamicHaptic(haptics: haptics)
                        }
                        .buttonStyle(.bordered)
                        Text("or click the counter above!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                } header: {
                    Text("Haptics")
                }
                .onChange(of: hapticDuration + hapticIntensity + hapticSharpness) {
                    haptics = [Haptic(intensity: hapticIntensity, sharpness: hapticSharpness, interval: hapticDuration)]
                }
            }
        }
        
        .onAppear {
            prepareHaptics()
        }
    }
    func designName(_ design: Font.Design) -> String {
        switch design {
        case .default: return "Default"
        case .monospaced: return "Monospaced"
        case .rounded: return "Rounded"
        case .serif: return "Serif"
        @unknown default: return "Unknown"
        }
    }
    
    struct Haptic: Hashable {
        var intensity: CGFloat
        var sharpness: CGFloat
        var interval: CGFloat
    }
    
    @State var haptics: [Haptic] = [
        Haptic(intensity: 1.0, sharpness: 1, interval: 0.5),
        //Haptic(intensity: 1.0, sharpness: 0.0, interval: 1.5)
    ]
    
    func dynamicHaptic(haptics: [Haptic]) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.0)
        let intervals: [CGFloat] = haptics.map({ $0.interval })
        let totalDuration: TimeInterval = TimeInterval(intervals.reduce(0, +))
        var dynamicIntensity = [CHHapticDynamicParameter]()
        var dynamicSharpness = [CHHapticDynamicParameter]()
        
        for haptic in haptics {
            dynamicIntensity.append(CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: Float(haptic.intensity), relativeTime: 0))
            dynamicSharpness.append(CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: Float(haptic.sharpness), relativeTime: 0))
        }
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: totalDuration)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: 0)
            
            for index in 0..<haptics.count {
                let relativeInterval: TimeInterval = TimeInterval(intervals[0...index].reduce(-intervals[index], +))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + relativeInterval) {
                    do {
                        try player?.sendParameters([dynamicIntensity[index], dynamicSharpness[index]], atTime: CHHapticTimeImmediate)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error creating the engine: (error.localizedDescription)")
        }
        
        engine?.resetHandler = {
            print("Restarting haptic engine")
            do {
                try self.engine?.start()
            } catch {
                fatalError("Failed to restart the engine: (error)")
            }
        }
    }
}

#Preview {
    @Previewable @State var count: Database = Database()
    FontEditor(count: $count)
}
