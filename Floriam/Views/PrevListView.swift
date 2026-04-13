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
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \PlantRecord.date, order: .reverse) var plantlist: [PlantRecord]
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color.green.opacity(0.3),Color.blue.opacity(0.2),Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green.opacity(0.8))
                .padding(10)
                
                List {
                    ForEach(plantlist) { plant in
                        ListRowView(plantRecord: plant)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let plant = plantlist[index]
            modelContext.delete(plant)
        }
        
        try? modelContext.save()
    }
}

struct ListRowView: View {
    @Environment(PlantNetManager.self) private var netManager
    @Environment(\.dismiss) var dismiss
    
    let plantRecord: PlantRecord
    
    var body: some View {
        HStack {
            ForEach(plantRecord.imagePaths, id: \.self) { path in
                if let uiImage = netManager.imgService.getImage(from: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .clipped()
                }
            }
            VStack(alignment: .leading) {
                ForEach(plantRecord.bestNames, id: \.self) { name in
                    Text(name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding(10)
        }
    }
}
