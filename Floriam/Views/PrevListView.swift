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
    
    @Query(sort: \PlantRecord.date) var plantlist: [PlantRecord]
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.3),Color.blue.opacity(0.2),Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            List(plantlist) { plant in
                ListRowView(plantRecord: plant)
                    .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
}

struct ListRowView: View {
    @Environment(PlantNetManager.self) private var netManager
    
    let plantRecord: PlantRecord
    
    var body: some View {
        HStack {
            ForEach(plantRecord.imagePaths, id: \.self) { path in
                if let uiImage = netManager.imgService.getImage(from: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
            }
            VStack(alignment: .leading) {
                ForEach(plantRecord.bestNames, id: \.self) { name in
                    Text(name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}


/*
struct ListRowView: View {
    @Environment(PlantNetManager.self) private var netManager
    
    let plantRecord: PlantRecord
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(plantRecord.imagePaths, id: \.self) { path in
                        if let uiImage = netManager.imgService.getImage(from: path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        }
                    }
                }
            }
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    ForEach(plantRecord.bestNames, id: \.self) { name in
                        Text(name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}
*/
