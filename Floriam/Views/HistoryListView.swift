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
    @Environment(PlantNetManager.self) private var netManager
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \PlantRecord.date, order: .reverse) var plantlist: [PlantRecord]
    
    @State private var sharedImage: ImageItem?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            backGradient.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green.opacity(0.8))
                .padding(10)
                
                List {
                    ForEach(plantlist) { plant in
                        ListRowView(plantRecord: plant, sharedImage: $sharedImage)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
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
    @Environment(PlantNetManager.self) private var netManager
    
    let plantRecord: PlantRecord
    @Binding var sharedImage: ImageItem?
    
    var body: some View {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(plantRecord.imagePaths, id: \.self) { path in
                            if let uiImage = netManager.getImage(from: path) {
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
#if targetEnvironment(macCatalyst)
                            TextEditor(text: .constant(name))
                                .font(.title3)
                                .frame(height: 35)
                                .scrollDisabled(true)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
#else
                            Text(name)
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
#endif
                        }
                    }
                }
                .padding(10)
            }
    }
}
