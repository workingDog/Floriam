//
//  DiseaseView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/15.
//
import Foundation
import SwiftUI
import GeminiKitAPI


struct DiseaseView: View {
    @Environment(PlantNetManager.self) private var netManager
    @Environment(AiManager.self) private var aiManager

    let description: String?

    @State private var isLoading = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppTheme.backGradient.ignoresSafeArea()
            VStack {

                Text(description ?? "no info").font(.title)

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
        .task(id: description) {
            aiManager.aiReply = ""
            if aiManager.aiAvailable {
                isLoading = true
                aiManager.currentSkill = aiManager.PlantDiseaseSkill
                await aiManager.getResponse(from: description ?? "no info", mode: "plant disease")
                isLoading = false
            }
        }
    }

}
