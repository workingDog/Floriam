//
//  ImageService.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/12.
//
import Foundation
import SwiftUI
import SwiftData


class ImageService {
 
    var modelContext: ModelContext?
    
    init() { }

    func saveImage(_ data: Data) throws -> String {
        let filename = UUID().uuidString + ".jpeg"
        let url = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        try data.write(to: url)
        return url.path
    }
    
    func getImage(from path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
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
