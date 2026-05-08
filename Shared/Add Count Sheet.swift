//
//  Add Count Sheet.swift
//  Counter App
//
//  Created by Jack Kroll on 1/10/26.
//  Copyright © 2026 JackKroll. All rights reserved.
//

import SwiftUI
import SwiftData

struct AddCountSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Binding var showSheet: Bool
    @State var title: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField(LocalizedStringKey("Count Title"), text: $title)
                }
                Button {
                    let count = Database(
                        date: .now,
                        number: 0,
                        step: 1,
                        theme: ["Lead", "Copper", "Bismuth", "Bronze", "Platinum", "Gold"].randomElement()!,
                        title: title.isEmpty ? "Untitled" : title
                    )
                    modelContext.insert(count)
                    try? modelContext.save()
                    withAnimation {
                        dismiss()
                        showSheet = true
                    }
                } label: {
                    Text(LocalizedStringKey("Create Count"))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(.blue)
                .modifier {
                    if #available(iOS 26, *) {
                        $0.clipShape(ConcentricRectangle(corners: .concentric(minimum: 12),isUniform: true))
                    } else {
                        $0.clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("Create Count"))
            .navigationBarTitleDisplayMode(.inline)
        }
        
        
    }
}

#Preview {
    @Previewable @State var showSheet: Bool = false
    AddCountSheet(showSheet: $showSheet)
        .modelContainer(PreviewDatabase.container())
}
