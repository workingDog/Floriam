//
//  KeyView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/13.
//

import Foundation
import SwiftUI


struct KeyView: View {
    @Environment(\.dismiss) var dismiss

    @State private var theKey = ""
    
    var body: some View {
        ZStack {
            backGradient.ignoresSafeArea()
            
            VStack (alignment: .leading, spacing: 60) {
                HStack {
                    Button("Done") {
                        dismiss()
                    }.padding(10)
                    Spacer()
                }.padding(10)

                HStack {
                    Spacer()
                    VStack (spacing: 20) {
                        Text("Copy your API key from")
                        Text("[Pl@ntNet](https://my.plantnet.org/)")
                    }
                    Spacer()
                }.padding(.top, 50)
                
                CustomSecureField(password: $theKey)
                    .foregroundStyle(.blue)
                    .textFieldStyle(CustomTextFieldStyle())
                    .padding(.top, 50)
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
