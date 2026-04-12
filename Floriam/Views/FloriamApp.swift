//
//  FloriamApp.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//

import SwiftUI
import SwiftData


//  see https://github.com/plantnet/status
//      https://my.plantnet.org/doc/api/openapi


@main
struct FloriamApp: App {
    
       @State var netManager = PlantNetManager()
       
       var sharedModelContainer: ModelContainer = {
           let schema = Schema([PlantRecord.self])
           let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
           
           do {
               let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
               
               if let url = container.configurations.first?.url {
                   print("---> SwiftData store URL: \(url)")
               }
               
               return container
           } catch {
               fatalError("Could not create ModelContainer: \(error)")
           }
       }()

       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environment(netManager)
           }
           .modelContainer(sharedModelContainer)
       }
   }
