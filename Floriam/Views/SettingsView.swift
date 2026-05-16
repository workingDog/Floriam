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
    
    @State private var showAIKey = false
    @State private var showPlantKey = false
    
    
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
                    Button(action: {showPlantKey = true}) {
                        Text("Set PlantNet key").padding(15)
                    }
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.green))
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    Spacer()
                    Button(action: {showAIKey = true}) {
                        Text("Set Google AI key").padding(15)
                    }
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.green))
                    Spacer()
                }
                
                Spacer()
            }
            .sheet(isPresented: $showAIKey) {
                AIKeyView()
            }
            .sheet(isPresented: $showPlantKey) {
                PlantKeyView()
            }
        }
    }
    
}
