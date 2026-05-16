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
    var model: GeminiModel = GeminiModel("gemini-2.5-flash")

    init() {
        let apikey = KeychainInterface.getPassword(account: aiAccount) ?? ""
  //      print("\n----> apikey: \(apikey) \n")
        if apikey.isEmpty {
            self.aiAvailable = false
            print("\n----> No AI api key found \n")
        } else {
            self.aiAvailable = true
        }
        self.client = GeminiKit(apiKey: apikey)
        self.model = GeminiModel("gemini-2.5-flash")  // "gemini-3-flash-preview"
        self.currentSkill = PlantInfoSkill
    }
    
    func updateClientKey(_ apikey: String) {
        client = GeminiKit(apiKey: apikey)
    }
    
    func getResponse(from text: String, mode: String) async {
        errorDetected = false
        await getChats(from: text, mode: mode)
        haveResponse.toggle()
    }

    func getChats(from text: String, mode: String) async {
        let chatText = """
        Provide practical information about this \(mode) in simple English.

        Use short Markdown sections.

        Input:
        \(text)
        """
  
        do {
            let chat = client.startChat(model: model, systemInstruction: currentSkill)
            aiReply = try await chat.sendMessage(chatText)
        } catch {
            errorDetected = true
            print("----> AI Gemini error: \(error) with \n \(chatText) \n \(currentSkill.prefix(20))  \n")
        }
    }
    
    let PlantDiseaseSkill = """
    ---
    name: plant_disease_info
    description: Explain plant diseases clearly for gardeners and beginners.
    version: 1.1.0
    ---

    # Plant Disease Skill

    ## Purpose
    Explain plant diseases in clear, beginner-friendly language for gardeners.

    ## Instructions
    1. Identify the disease, pathogen, or pest.
    2. Explain:
       - what it is
       - affected plants
       - symptoms and visible signs
       - how it spreads or develops
    3. Provide practical gardening guidance:
       - prevention methods
       - treatment or management options
       - ways to reduce future outbreaks
    4. Clearly state uncertainty when information is incomplete.

    ## Output Rules
    - Use Markdown formatting.
    - Use short sections with headers.
    - Use bullet points where appropriate.
    - Keep explanations concise and practical.
    - Write for non-expert gardeners.

    ## Constraints
    - Do not invent facts.
    - Do not provide unsafe chemical advice.
    - Do not hide uncertainty.
    - Stay focused on explanation and gardening guidance.
    """
    
    let PlantInfoSkill = """
    ---
    name: plant_info
    description: Explain plants clearly for gardeners and beginners.
    version: 1.1.0
    ---

    # Plant Information Skill

    ## Purpose
    Explain plants in clear, beginner-friendly language for gardeners.

    ## Instructions
    1. Identify the plant species or common name.
    2. Explain:
       - what the plant is
       - its notable characteristics
       - growth habits and appearance
       - typical environment or climate
    3. Provide practical gardening information:
       - watering
       - sunlight needs
       - soil preferences
       - maintenance tips
    4. Mention common problems or risks if relevant.
    5. Clearly state uncertainty when information is incomplete.

    ## Output Rules
    - Use Markdown formatting.
    - Use short sections with headers.
    - Use bullet points where appropriate.
    - Keep explanations concise and practical.
    - Write for non-expert gardeners.

    ## Constraints
    - Do not invent facts.
    - Do not provide dangerous gardening advice.
    - Do not hide uncertainty.
    - Stay focused on explanation and gardening guidance.
    """
    
}
