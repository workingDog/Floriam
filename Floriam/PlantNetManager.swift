//
//  PlantNetManager.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//
import Foundation
import SwiftUI



@Observable class PlantNetManager {
    
    @ObservationIgnored let apiKey: String
    
    let baseURL = "https://my-api.plantnet.org/v2"
    
    var netResponse: PlantNetResponse?
    
    init() {
        self.apiKey = StoreService.getKey() ?? ""
      //  print("---> apiKey: \(apiKey)")
    }

    func checkStatus() async {
        if let url = URL(string: "\(baseURL)/_status/?api-key=\(apiKey)") {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                try validate(response: response, data: data)
                //     return try JSONDecoder().decode([xxx].self, from: data)
                
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("---> checkStatus message: \(message)")
            } catch {
                print(error)
            }
        } else {
            print("url is not valid")
        }
    }
    
    func identify(project: String = "all", images: [Data], organs: [String]? = nil) async throws -> PlantNetResponse {
        
        var components = URLComponents(string: "\(baseURL)/identify/\(project)")!
        components.queryItems = [
            URLQueryItem(name: "api-key", value: apiKey)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        for (index, imageData) in images.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        if let organs {
            for organ in organs {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"organs\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(organ)\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
        
        return try JSONDecoder().decode(PlantNetResponse.self, from: data)
    }
    
    func fetchProjects() async throws -> [Project] {
        let url = URL(string: "\(baseURL)/projects?api-key=\(apiKey)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder().decode([Project].self, from: data)
    }
    
    func fetchAllSpecies() async throws -> [SpeciesListItem] {
        let url = URL(string: "\(baseURL)/species?api-key=\(apiKey)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder().decode([SpeciesListItem].self, from: data)
    }
    
    func fetchSpecies(project: String) async throws -> [SpeciesListItem] {
        let url = URL(string: "\(baseURL)/projects/\(project)/species?api-key=\(apiKey)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response, data: data)
        return try JSONDecoder().decode([SpeciesListItem].self, from: data)
    }
    
    func survey(project: String, image: Data) async throws -> SurveyResponse {
        var components = URLComponents(string: "\(baseURL)/survey/tiles/\(project)")!
        components.queryItems = [URLQueryItem(name: "api-key", value: apiKey)]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
        
        return try JSONDecoder().decode(SurveyResponse.self, from: data)
    }
    
    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        
        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
        
        switch http.statusCode {
        case 200..<300: return
        case 401: throw APIError.apiError(reason: "Unauthorized")
        case 402: throw APIError.apiError(reason: "Quota exceeded")
        case 403: throw APIError.apiError(reason: "Resource forbidden")
        case 404: throw APIError.apiError(reason: "Resource not found")
        case 429: throw APIError.apiError(reason: "Requesting too quickly")
        case 405..<500: throw APIError.apiError(reason: "Client error")
        case 500..<600: throw APIError.apiError(reason: "Server error")
        default: throw APIError.apiError(reason: message)
        }
    }
}

enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    var errorDescription: String? {
        switch self {
        case .unknown: return "Unknown error"
        case .apiError(let reason), .parserError(let reason): return reason
        case .networkError(let from): return from.localizedDescription
        }
    }
}


