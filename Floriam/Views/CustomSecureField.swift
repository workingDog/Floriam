//
//  CustomSecureField.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/13.
//

import Foundation
import SwiftUI

// from: https://stackoverflow.com/questions/70491417/toggle-issecuretextentry-in-swiftui-for-securefield


struct CustomSecureField: View {
    @Binding var password: String
    
    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if password.isEmpty {
                    HStack {
                        Text("")
                        Spacer()
                    }
                }
                ZStack {
                    TextField("", text: $password)
                    .frame(maxHeight: .infinity)
                    .opacity(isPasswordVisible ? 1 : 0)
                    
                    SecureField("", text: $password)
                    .frame(maxHeight: .infinity)
                    .opacity(isPasswordVisible ? 0 : 1)
                }
            }
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
            }
            .padding(.trailing, 5)
        }
        .frame(height: 46)
        .frame(maxWidth: .infinity)
        .cornerRadius(5)
    }
    
}

public struct CustomTextFieldStyle : TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.callout)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.blue, lineWidth: 2))
    }
}
