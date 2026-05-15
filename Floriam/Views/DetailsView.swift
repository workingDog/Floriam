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
                            Text("Scientific names").font(.title).padding(10)
                            ForEach(results) { result in
                                if let species = result.species {
                                    if let name = species.scientificName {
                                        Text(name)
                                            .font(.title3)
                                            .textSelection(.enabled)
                                            .padding(.horizontal, 10)
                                    }
                                }
                            }
                        } else {
                            Text("Possible diseases").font(.title).padding(10)
                            ForEach(results) { plant in
                                VStack {
                                    Text(plant.name ?? "no name").font(.title3)
                                    Text(plant.description ?? "no info").font(.title3)
                                    Divider()
                                }
                                .textSelection(.enabled)
                                .padding(.horizontal, 10)
                            }
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .task {
            if let info = netManager.netResponse?.results {
                results = info
            }
        }
    }
}
