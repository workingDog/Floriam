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
            LinearGradient(
                colors: [Color.green.opacity(0.3),Color.blue.opacity(0.2),Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                        Text("Copy your key from")
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
                theKey = StoreService.getKey() ?? ""
            }
        }
    }
    
    func doSaveKey() {
        if StoreService.getKey() == nil {
            StoreService.setKey(key: theKey)
        } else {
            StoreService.updateKey(key: theKey)
        }
        dismiss()
    }
}
