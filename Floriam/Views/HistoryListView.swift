//
//  HistoryListView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/12.
//
import SwiftUI
import SwiftData


struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \PlantRecord.date, order: .reverse) var plantlist: [PlantRecord]
    
    @State private var sharedImage: ImageItem?
    @State private var selectedPlant: PlantRecord?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                AppTheme.backGradient.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    HStack {
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .padding(5)
                        Spacer()
                    }.padding(8)
                    
                    List {
                        ForEach(plantlist) { plant in
                            ListRowView(plantRecord: plant, sharedImage: $sharedImage)
                                .contentShape(Rectangle())
                                .simultaneousGesture(
                                    TapGesture().onEnded {
                                        selectedPlant = plant
                                    }
                                )
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .navigationDestination(item: $selectedPlant) { plant in
                MKView(text: plant.info)
            }
        }
        .sheet(item: $sharedImage) { item in
            ShareSheet(items: [item.uimage])
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
    let plantRecord: PlantRecord
    @Binding var sharedImage: ImageItem?
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(plantRecord.imagePaths, id: \.self) { path in
                        if let uiImage = PlantNetManager.getImage(from: path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .clipped()
                                .onLongPressGesture {
                                    sharedImage = ImageItem(uimage: uiImage)
                                }
                        }
                    }
                }
            }.padding(10)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    ForEach(plantRecord.bestNames, id: \.self) { name in
                        Text(name)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(10)
        }
    }
}
