//
//  Models.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//

import Foundation
import SwiftData
import UIKit


@Model
final class PlantRecord {
    @Attribute(.unique) var plantId: UUID
    var date: Date
    var imagePaths: [String]
    var bestNames: [String]
    var score: Double

    init(imagePaths: [String], bestNames: [String], score: Double) {
        self.plantId = UUID()
        self.date = Date()
        self.imagePaths = imagePaths
        self.bestNames = bestNames
        self.score = score
    }
}


extension UIImage {
    
    func resizedToFitWidth(_ targetWidth: CGFloat) -> UIImage {
        let scale = targetWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: targetWidth, height: newHeight)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
  
}

struct ImageItem: Identifiable, Hashable {
    let id = UUID()
    var uimage: UIImage
    
    var imgData: Data? {
        let resized = uimage.resizedToFitWidth(1280)
        return resized.jpegData(compressionQuality: 0.9)
    }

}

struct PlantNetResponse: Codable {
    let query: Query
    let predictedOrgans: [PredictedOrgan]?
    let language, preferedReferential, bestMatch: String?
    let results: [PlantNetResult]
    let version: String?
    let remainingIdentificationRequests: Int?
    
    var bestResult: PlantNetResult? {
        results.max(by: { $0.score < $1.score })
    }
}

// organ: auto, leaf, flower, fruit, bark, habit, scan, branch, sheet, other, drawing, seed, bud, anatomy, aerial
struct PredictedOrgan: Identifiable, Hashable, Codable {
    let id = UUID()
    
    let image, filename, organ: String?
    let score: Double?
}

struct Query: Codable {
    let project: String?
    let images, organs: [String]?
    let includeRelatedImages, noReject: Bool?
}

struct PlantNetResult: Identifiable, Codable {
    let id = UUID()
    
    let score: Double
    let species: Species
}

struct Species: Codable {
    let scientificNameWithoutAuthor: String?
    let scientificNameAuthorship: String?
    let scientificName: String?
    let genus: Taxonomy?
    let family: Taxonomy?
    let commonNames: [String]?
    
    // todo
    var englishNames: [String]? {
        guard let commonNames else { return nil }
        return commonNames.filter { $0.canBeConverted(to: .ascii) }
    }
 
}

struct Taxonomy: Codable {
    let scientificNameWithoutAuthor: String?
    let scientificNameAuthorship: String?
    let scientificName: String?
}

struct Project: Codable {
    let id: String
    let name: String
    let type: String?
}

struct SpeciesListItem: Codable {
    let scientificName: String
    let family: String?
    let genus: String?
}

struct SurveyResponse: Codable {
    let status: String
    let query: SurveyQuery?
    let results: SurveyResults?
}

struct SurveyQuery: Codable {
    let project: String?
}

struct SurveyResults: Codable {
    let nb_sub_queries: Int
    let nb_matching_sub_queries: Int
    let uncovered: Double
}
