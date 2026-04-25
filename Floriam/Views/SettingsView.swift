//
//  SettingsView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/13.
//

import Foundation
import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("maxHistory") private var maxHistory = 10.0

    @State private var theKey = ""
    
    var body: some View {
        ZStack {
            AppTheme.backGradient.ignoresSafeArea()
            
            VStack (alignment: .leading, spacing: 30) {
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .padding(5)
                    Spacer()
                }.padding(8)

                VStack {
                    Text("Number of Photos to Keep").padding(10)
                    Text("\(Int(maxHistory))")
                    Slider(value: $maxHistory, in: 10...50, step: 1.0).padding(8)
                }
                
                Divider()
                
                HStack {
                    Spacer()
                    VStack (spacing: 20) {
                        Text("Add your key from")
                        Text("[Pl@ntNet](https://my.plantnet.org/)")
                    }
                    Spacer()
                }.padding(.top, 20)
                
                CustomSecureField(password: $theKey)
                    .foregroundStyle(.blue)
                    .textFieldStyle(CustomTextFieldStyle())
                    .padding(.top, 20)
                    .padding(.horizontal, 8)
                
                HStack {
                    Spacer()
                    Button(action: doSaveKey ) {
                        Text("Save").padding(10)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                
                Spacer()
            }
            .onAppear {
                theKey = KeychainInterface.getKey() ?? ""
            }
        }
    }
    
    func doSaveKey() {
        if KeychainInterface.getKey() == nil {
            KeychainInterface.setKey(key: theKey)
        } else {
            KeychainInterface.updateKey(key: theKey)
        }
        dismiss()
    }
}
