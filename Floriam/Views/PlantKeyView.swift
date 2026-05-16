//
//  PlantKeyView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/16.
//
import Foundation
import SwiftUI


struct PlantKeyView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var theKey = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            AppTheme.backGradient.ignoresSafeArea()
            
            VStack (alignment: .leading, spacing: 60) {
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .padding(5)
                    Spacer()
                }.padding(8)

                HStack {
                    Spacer()
                    VStack (spacing: 20) {
                        Text("Add your key from")
                        Text("[PlantNet](https://my.plantnet.org/)")
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
