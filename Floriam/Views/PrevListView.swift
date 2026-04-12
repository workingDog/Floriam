//
//  PrevListView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/12.
//
import SwiftUI
import SwiftData


struct PrevListView: View {
    @Environment(PlantNetManager.self) private var netManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var plantlist: [PlantRecord] = []
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.3),Color.blue.opacity(0.2),Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                List(plantlist) { plant in
                    ListRowView(plantRecord: plant)
                        .border(.blue)
                }
            }
        }
        .onAppear {
            plantlist.append(PlantRecord(imagePaths: ["path-1"], bestNames: ["test-1"], score: 0.5))
            plantlist.append(PlantRecord(imagePaths: ["path-2"], bestNames: ["test-2"], score: 0.5))
            plantlist.append(PlantRecord(imagePaths: ["path-3"], bestNames: ["test-3"], score: 0.5))
        }
    }
}

struct ListRowView: View {
   let plantRecord: PlantRecord
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(plantRecord.imagePaths, id: \.self) { path in
                        Text(path)
                            .frame(width: 200, height: 200)
                            .border(.red)
                    }
                }
            }
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    ForEach(plantRecord.bestNames, id: \.self) { name in
                        Text(name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 100)
                            .border(.green)
                    }
                }
            }
        }
    }
}
