//
//  DetailsView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/15.
//
import Foundation
import SwiftUI


struct DetailsView: View {
    @Environment(PlantNetManager.self) private var netManager
    
    @State private var results: [PlantNetResult] = []
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            AppTheme.backGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if netManager.displayNames.isEmpty {
                        Text("No results")
                    } else {
                        if netManager.identifyMode {
                            ForEach(results) { result in
                                if let species = result.species {
                                    if let name = species.scientificName {
                                        NavigationLink {
                                            InfoView(name: name, description: species.englishNames?.first)
                                        } label: {
                                            Text(name).font(.title3)
                                        }
                                    }
                                }
                                Divider()
                            }
                            .navigationTitle("Scientific names")
                        } else {
                            ForEach(results) { plant in
                                NavigationLink {
                                    DiseaseView(name: plant.name, description: plant.description)
                                } label: {
                                    VStack {
                                        Text(plant.name ?? "no name").font(.title3)
                                        Text(plant.description ?? "no info").font(.title3)
                                    }
                                }
                                Divider()
                            }
                            .navigationTitle("Possible diseases")
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .task {
            if let info = netManager.netResponse?.results {
                results = info
            }
        }
    }
}
