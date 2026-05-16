//
//  AiManager.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/15.
//
import Foundation
import SwiftUI
import GeminiKitAPI


@Observable class AiManager {
    
    let aiAccount = "ringow.gemini.floriam"
    
    var aiReply: String = ""
    var currentSkill: String = ""
    
    var errorDetected = false
    var haveResponse = false
    var aiAvailable = false
    
    @ObservationIgnored var client = GeminiKit(apiKey: "your-api-key")

    var config: GenerationConfig = GenerationConfig(maxOutputTokens: 1000)
    var model: GeminiModel = GeminiModel("gemini25Flash")

    init() {
        let apikey = KeychainInterface.getPassword(account: aiAccount) ?? ""
        if apikey.isEmpty {
            self.aiAvailable = false
            print("\n----> No AI api key found \n")
        } else {
            self.aiAvailable = true
        }
        self.client = GeminiKit(apiKey: apikey)
        self.model = GeminiModel("gemini-3-flash-preview")
        self.currentSkill = PlantDiseaseSkill
    }
    
    func updateClientKey(_ apikey: String) {
        client = GeminiKit(apiKey: apikey)
    }
    
    func getResponse(from text: String) async {
        errorDetected = false
        await getChats(from: text)
        haveResponse.toggle()
    }

    func getChats(from text: String) async {
        do {
            let history: [Content] = []

            let chat = client.startChat(
                model: model,
                systemInstruction: currentSkill,
                history: history)
            
            aiReply = try await chat.sendMessage(text)
        } catch {
            errorDetected = true
            print("----> error: \(error)")
        }
    }
    
    let PlantDiseaseSkill = """
    ---
    name: plant_disease_info
    description: A base template for explaining a plant disease.
    version: 1.0.0
    ---

    # Plant Disease Skill

    ## When to Use
    Use this skill as a baseline template when explaining a plant disease.

    ## Instructions
    1. **Analyze Input**: Identify the specific plant disease of the user request.
    2. **Explaining Scope**: Explain in plain English the disease impact and reasons.
    3. **Recomendations**: Propose remedial actions, treatments and preventions.
    4. **Refine Output**: Ensure the response targets a gardener.

    ## Output Rules
    - Provide clear, structured responses using Markdown.
    - Use headers to organize information.
    - Use bullet points for lists.

    ## Constraints
    - Do not make up facts or data that cannot be verified from the context.
    - Do not perform actions apart from giving advice.
    - Maintain a professional and helpful tone.
    """
    
}
