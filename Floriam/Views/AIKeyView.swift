//
//  AIKeyView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/16.
//
import Foundation
import SwiftUI


struct AIKeyView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AiManager.self) var aiManager
    
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
                        Text("Copy your key from")
                        Text("[Google AI](https://ai.google.dev/)")
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
                theKey = KeychainInterface.getPassword(account: aiManager.aiAccount) ?? ""
            }
        }
    }
    
    func doSaveKey() {
        if KeychainInterface.getPassword(account: aiManager.aiAccount) == nil {
            KeychainInterface.savePassword(password: theKey, account: aiManager.aiAccount)
        } else {
            KeychainInterface.updatePassword(password: theKey, account: aiManager.aiAccount)
        }
        aiManager.updateClientKey(theKey)
        dismiss()
    }
}

