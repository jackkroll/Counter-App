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
        GeometryReader{ geo in
            VStack{
                HStack{
                    Text("v2.1 Improvements")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding()
                }
                ScrollView{
                VStack{
                    HStack{
                        Text("• Quick access +/- buttons")
                            .padding()
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                        VStack{
                            HStack{
                                Text("• Updated colors")
                                    .padding()
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            HStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .padding(3)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(CustomColor.red)
                                    .shadow(radius: 5)
                                RoundedRectangle(cornerRadius: 10)
                                    .padding(3)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(CustomColor.yellow)
                                    .shadow(radius: 5)
                                RoundedRectangle(cornerRadius: 10)
                                    .padding(3)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(CustomColor.green)
                                    .shadow(radius: 5)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .padding(3)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(CustomColor.blue)
                                    .shadow(radius: 5)
                                RoundedRectangle(cornerRadius: 10)
                                    .padding(3)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(CustomColor.pink)
                                    .shadow(radius: 5)
                                RoundedRectangle(cornerRadius: 10)
                                    .padding(3)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .shadow(radius: 5)
                            }
                            
                        }
                        
                        HStack{
                            Text("• Drag to arrange counts")
                                .padding()
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        
                    }
                    .padding()
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
                .frame(width: geo.size.width * 0.9)
                .onTapGesture {
                    dismiss()
                }
            }
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
        GeometryReader{geo in
        VStack{
            
            Text("Enjoying Counter App?")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
           
                HStack{
                    Spacer()
                    Text("Not Really")
                        .frame(width: geo.size.width * 0.4, height: 50)
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
                    
                    Text("Love it")
                        .frame(width: geo.size.width * 0.4, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            review()
                            dismiss()
                        }
                    Spacer()
                }
            Spacer()
                .frame(height: 20)
            HStack{
                Spacer()
                Text("Don't show this again")
                Spacer()
            }
            .foregroundColor(.white)
            .cornerRadius(15)
            .fontWeight(.semibold)
            .onTapGesture {
                reviewMute = true
                dismiss()
            }
            .frame(width: geo.size.width * 0.8, height: 40)
            .background(Color.gray)
            .cornerRadius(10)
            }
            
        }
        
    
    }
}

struct Supplemental_Views_Previews: PreviewProvider {
    static var previews: some View {
       UpdateLog()
    }
}
