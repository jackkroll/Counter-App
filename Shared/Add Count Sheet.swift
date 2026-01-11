//
//  Add Count Sheet.swift
//  Counter App
//
//  Created by Jack Kroll on 1/10/26.
//  Copyright © 2026 JackKroll. All rights reserved.
//

import SwiftUI

struct AddCountSheet: View {
    @Environment(\.managedObjectContext) var moc
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
                    let count = Database(context: moc)
                    count.number = Int64(0)
                    count.step = 1
                    count.title = title.isEmpty ? "Untitled" : title
                    count.theme = ["Lead", "Copper", "Bismuth", "Bronze", "Platinum", "Gold"].randomElement()!
                    count.date = .now
                    count.uuid = UUID()
                    try? moc.save()
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
}
