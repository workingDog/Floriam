//
//  InfoView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/16.
//
import Foundation
import SwiftUI
import GeminiKitAPI


struct InfoView: View {
    @Environment(AiManager.self) private var aiManager
    
    let name: String?
    let description: String?

    @State private var isLoading = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppTheme.backGradient.ignoresSafeArea()
            VStack {
                VStack {
                    Text(name ?? "no name").font(.title)
                    Text(description ?? "no info").font(.title)
                }
                if aiManager.aiAvailable {
                    MKView(text: aiManager.aiReply).padding(.top, 10)
                } else {
                    VStack {
                        Text("No AI information is available").font(.title)
                        Text("Enter the required Google AI key").font(.title)
                    }.padding(.top, 20)
                }
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(2.0)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Spacer()
            }
        }
        .task(id: name) {
            if aiManager.aiAvailable {
                isLoading = true
                aiManager.currentSkill = aiManager.PlantInfoSkill
                await aiManager.getResponse(from: description ?? "no info")
                isLoading = false
            }
        }
    }

}

