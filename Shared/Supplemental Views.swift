//
//  Supplemental Views.swift
//  Counter App
//
//  Created by Jack Kroll on 1/4/23.
//  Copyright © 2023 JackKroll. All rights reserved.
//

import SwiftUI
import StoreKit

struct UpdateLog: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
            VStack{
                HStack{
                    Text(LocalizedStringKey("v2.6 Improvements"))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding()
                }
                    Form {
                        
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("- Optional Customization Pack"))
                            Text(LocalizedStringKey("Support ongoing development and unlock new customization features"))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .listRowSeparator(.hidden)
                        
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("- Database Upgrade"))
                            Text(LocalizedStringKey("Database migrated to a modern standard"))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .listRowSeparator(.hidden)
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("- Localization Updates"))
                            Text(LocalizedStringKey("Localization is now more accurate"))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .listRowSeparator(.hidden)
                        
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("Thank you for using Counter"))
                        }
                        .listRowSeparator(.hidden)
                        
                    }
                    
                    
                    
                    Spacer()
                    HStack{
                        Spacer()
                        Text("👍")
                        Spacer()
                    }
                    .padding()
                    .background(.blue)
                    .cornerRadius(15)
                    .fontWeight(.semibold)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        dismiss()
                    }
                    .padding()
            }
            .interactiveDismissDisabled()
            
    }
}

struct ReviewApp: View{
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.requestReview) var review
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("neverShowReview") var reviewMute: Bool = false
    
    var body: some View{
            VStack{
                
                Text(LocalizedStringKey("Enjoying Counter App?"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                
                HStack{
                    Text(LocalizedStringKey("Not Really"))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            let mailtoString = "mailto:support@jackk.dev?subject=Counting App Feedback".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            let mailtoUrl = URL(string: mailtoString!)!
                            if UIApplication.shared.canOpenURL(mailtoUrl) {
                                UIApplication.shared.open(mailtoUrl, options: [:])
                            }
                            
                            dismiss()
                        }
                    
                    Text(LocalizedStringKey("Love it"))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            review()
                            dismiss()
                        }
                }
                HStack{
                    Spacer()
                    Text(LocalizedStringKey("Don't show this again"))
                    Spacer()
                }
                .padding()
                .foregroundColor(.white)
                .cornerRadius(15)
                .fontWeight(.semibold)
                .onTapGesture {
                    reviewMute = true
                    dismiss()
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(Color.gray)
                .cornerRadius(10)
            }
            .padding()
            
        }
}

struct Supplemental_Views_Previews: PreviewProvider {
    static var previews: some View {
        UpdateLog()
    }
}
