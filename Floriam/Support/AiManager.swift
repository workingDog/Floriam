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
        You are given the result of a plant identification system.

        Task:
        Explain the identified \(mode) in simple English for a beginner gardener.

        Important:
        - Treat the input as the most likely name from PlantNet.
        - If the name may be incomplete, ambiguous, or uncertain, say so clearly.
        - Keep the answer practical, concise, and easy to understand.
        - Use Markdown with short section headers.

        If mode is "plant", include:
        - What it is
        - Key features
        - Growing conditions
        - Water, light, and soil needs
        - Basic care tips
        - Common problems

        If mode is "plant disease", include:
        - What it is
        - Typical symptoms
        - Common causes
        - How serious it is
        - Basic treatment or management
        - Prevention tips
        - When the user should seek expert help

        Identified name:
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
    
    let PlantInfoSkill = """
    ---
    name: plant_explainer
    description: Explain identified plants and plant diseases clearly for beginners.
    version: 2.0.0
    ---

    # Plant and Plant Disease Explainer

    ## Purpose
    Explain identified plants or plant diseases in simple, practical English for home gardeners and beginners.

    ## General Instructions
    1. Assume the input is a label produced by a plant identification tool such as PlantNet.
    2. Explain the provided label clearly and practically.
    3. If the label is uncertain, ambiguous, too broad, or possibly incorrect, say that clearly.
    4. Keep the answer concise, useful, and safe.

    ## If the input is a plant
    Explain:
    - what the plant is
    - notable characteristics
    - growth habit and appearance
    - usual climate or environment
    - watering needs
    - sunlight needs
    - soil preferences
    - maintenance tips
    - common issues

    ## If the input is a plant disease
    Explain:
    - what the disease is
    - common symptoms
    - likely causes
    - how it spreads or develops if relevant
    - treatment or management options
    - prevention tips
    - whether urgent action may be needed

    ## Output Rules
    - Use Markdown.
    - Use short sections with headers.
    - Use bullet points when helpful.
    - Write for non-experts.
    - Prefer practical advice over technical detail.
    - Clearly separate confirmed facts from uncertainty.

    ## Constraints
    - Do not invent facts.
    - Do not pretend uncertain information is certain.
    - Do not give dangerous or unsafe treatment advice.
    - Do not recommend pesticides or chemicals casually; mention them carefully and generally unless the input is specific and confidence is high.
    """

}
