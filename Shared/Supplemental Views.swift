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
                    Text(LocalizedStringKey("v2.5 Improvements"))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding()
                }
                    Form {
                        
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("- Search for your counts"))
                            Text(LocalizedStringKey("Too many counts? Search for them now!"))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .listRowSeparator(.hidden)
                        
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("- iOS 26 Adoption"))
                            Text(LocalizedStringKey("This was only on a system componant level, the same experience you've used is untouched"))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .listRowSeparator(.hidden)
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("- Adjusted Navigation"))
                            Text(LocalizedStringKey("Counts now show entirely full screen"))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .listRowSeparator(.hidden)
                        
                        VStack(alignment: .leading){
                            Text(LocalizedStringKey("- New Add Count Sheet"))
                            Text(LocalizedStringKey("Streamlined creating a new count, it will now let you title it up front, and then it will send you right into it"))
                                .font(.callout)
                                .foregroundStyle(.secondary)
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
        ReviewApp()
    }
}
