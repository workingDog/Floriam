//
//  PlantNetManager.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//
import Foundation
import SwiftUI
import SwiftData


@Observable class PlantNetManager {
    
    @ObservationIgnored var modelContext: ModelContext?
    
    let apiKey: String
    let baseURL = "https://my-api.plantnet.org/v2"
    
    var netResponse: PlantNetResponse?
    
    init() {
        self.apiKey = KeychainInterface.getKey() ?? ""
    }
    
    func setContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveResult(_ imgData: [Data]) {
        guard let context = modelContext else { return }
        do {
            if let netResponse {
                var paths: [String] = []
                try imgData.forEach { data in
                    let path = try saveImage(data)
                    paths.append(path)
                }
                let bestNames = uniqueDisplayNames(top: 2)
                let bestScore = netResponse.bestResult?.score ?? 0.0
                let record = PlantRecord(imagePaths: paths, bestNames: bestNames, score: bestScore)
                context.insert(record)
                try context.save()
                
                try enforceLimit()
            }
        } catch {
            print(error)
        }
    }
    
    func topResults(top: Int) -> [PlantNetResult] {
        guard let netResponse else { return [] }
        return netResponse.results
            .sorted(by: { $0.score > $1.score }) // highest first
            .prefix(top)
            .map { $0 }
    }
    
    func uniqueDisplayNames(top: Int) -> [String] {
        let results = topResults(top: top)

        var seen = Set<String>()
        var names: [String] = []

        func appendIfNew(_ name: String?) {
            guard let name, !name.isEmpty else { return }
            guard seen.insert(name).inserted else { return }
            names.append(name)
        }

        for result in results {
            appendIfNew(result.species.scientificName)

            for name in result.species.englishNames ?? [] {
                appendIfNew(name)
            }
        }

        return names
    }

    func checkStatus() async {
        if let url = URL(string: "\(baseURL)/_status") {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                try validate(response: response, data: data)
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("---> checkStatus message: \(message)")
            } catch {
                print(error)
            }
        } else {
            print("url is not valid")
        }
    }
    
    func identify(project: String = "all", images: [Data], organs: [String]? = nil) async throws {
        
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
        
    //    print("---> response: \(String(data: data, encoding: .utf8) as AnyObject)")
        
        try validate(response: response, data: data)
        
        self.netResponse = try JSONDecoder().decode(PlantNetResponse.self, from: data)
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
            case 400: throw APIError.apiError(reason: "Bad Request")
            case 401: throw APIError.apiError(reason: "Unauthorized")
            case 404: throw APIError.apiError(reason: "Species Not Found")
            case 413: throw APIError.apiError(reason: "Payload Too Large")
            case 414: throw APIError.apiError(reason: "URI Too Long")
            case 415: throw APIError.apiError(reason: "Unsupported Media Type")
            case 429: throw APIError.apiError(reason: "Too Many Requests")
            case 500: throw APIError.apiError(reason: "Internal Server Error")
            case 405..<500: throw APIError.apiError(reason: "Client error")
            case 501..<600: throw APIError.apiError(reason: "Server error")
            default: throw APIError.apiError(reason: message)
        }
    }

    func saveImage(_ data: Data) throws -> String {
        let fm = FileManager.default
        let baseURL = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

        // Ensure directory exists
        try fm.createDirectory(at: baseURL, withIntermediateDirectories: true)

        let filename = UUID().uuidString + ".jpg"
        let fileURL = baseURL.appendingPathComponent(filename)

        try data.write(to: fileURL, options: .atomic)
        return fileURL.path
    }

    func getImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else {
            print("---> file not found at path:", path)
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
 
    // only keep the last 10 PlantRecords
    func enforceLimit() throws {
        let descriptor = FetchDescriptor<PlantRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        if let modelContext {
            let items = try modelContext.fetch(descriptor)
            if items.count > 10 {
                let toDelete = items.suffix(from: 10)
                for item in toDelete {
                    modelContext.delete(item)
                    // also delete image files
                    item.imagePaths.forEach { path in
                        try? FileManager.default.removeItem(atPath: path)
                    }
                }
            }
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




/*
 
 // todo
 
 import NaturalLanguage

 func detectLanguage(for text: String) -> NLLanguage? {
     let recognizer = NLLanguageRecognizer()
     recognizer.processString(text)
     return recognizer.dominantLanguage
 }
 
 func englishNames(from names: [String]) -> [String] {
     names.filter { name in
         detectLanguage(for: name) == .english
     }
 }
 
 if let names = best.species.commonNames {
     let english = englishNames(from: names)

     ForEach(english, id: \.self) { name in
         Text(name)
     }
 }
 
 func preferredNames(from names: [String]) -> [String] {
     names.filter { name in
         if let lang = detectLanguage(for: name) {
             return lang == .japanese || lang == .english
         }
         return false
     }
 }

 */
