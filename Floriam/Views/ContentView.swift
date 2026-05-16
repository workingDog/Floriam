//
//  ContentView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//

import SwiftUI
import SwiftData
import PhotosUI


enum SearchMode: String, CaseIterable, Hashable {
    case disease = "disease"
    case identify = "identify"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PlantNetManager.self) private var netManager
    @Environment(AiManager.self) private var aiManager
    
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var processing = false
    @State private var cameraCancel = false
    
    @State private var selectedImages: [ImageItem] = []
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var sharedImage: ImageItem?
    
    @State private var processingTask: Task<Void, Never>?
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backGradient.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button {
                            showCamera = true
                        } label: {
                            VStack {
                                Image(systemName: "camera").font(.title2)
                                Text("Camera").font(.caption)
                            }
                        }
                        Spacer()
                        
                        Button {
                            netManager.identifyMode.toggle()
                        } label: {
                            VStack {
                                Image(systemName: netManager.identifyMode ? "sparkle.magnifyingglass" : "leaf").font(.title2)
                                Text(netManager.identifyMode ? "Identify" : "Disease").font(.caption)
                            }
                        }
                        
                        Spacer()
                        Button {
                            showPhotoPicker = true
                        } label: {
                            VStack {
                                Image(systemName: "photo.on.rectangle").font(.title2)
                                Text("Photos").font(.caption)
                            }
                        }
                    }
                    .buttonStyle(.glass)
                    .disabled(processing)
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .background(.ultraThinMaterial)
                    
                    Divider()
                    
                    GeometryReader { geo in
                        VStack(alignment: .leading, spacing: 0) {
                            horizontalImagesView
                                .frame(height: geo.size.height * 2.0 / 3.0)
                            Divider()
                            NavigationLink {
                                DetailsView()
                            } label: {
                                verticalResultsView
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .tint(.green)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Button {
                            showHistory = true
                        } label: {
                            Image(systemName: "list.clipboard").font(.title)
                        }
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear").font(.title)
                        }
                    }
                }
            }
            .buttonStyle(.bordered)
            .disabled(processing)
        }
        .sheet(item: $sharedImage) { item in
            ShareSheet(items: [item.uimage])
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environment(aiManager)
        }
        .fullScreenCover(isPresented: $showCamera, onDismiss: doIdentify) {
            CameraView(selectedImages: $selectedImages, cameraCancel: $cameraCancel)
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryListView()
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItems)
        .task(id: photoItems) {
            guard !photoItems.isEmpty else { return }
            let items = photoItems
            await processPhotos(items)
            photoItems = []
        }
        .task(id: modelContext) {
            netManager.setContext(modelContext)
        }
    }
    
    @ViewBuilder
    var verticalResultsView: some View {
        if processing {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2.0)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text(netManager.identifyMode ? "Plant" : "Disease").foregroundStyle(Color.secondary).padding(10)

                    if netManager.displayNames.isEmpty {
                        Text("No results")
                    } else {
                        ForEach(netManager.displayNames, id: \.self) { name in
                            Text("-  \(name)")
                                .font(.title3)
                                .textSelection(.enabled)
                                .foregroundStyle(.black)
                        }
                    }
                }.padding(5)
            }
        }
    }
    
    @ViewBuilder
    var horizontalImagesView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedImages) { imgItem in
                    Image(uiImage: imgItem.uimage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFill()
                        .frame(maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .clipped()
                        .onLongPressGesture {
                            sharedImage = ImageItem(uimage: imgItem.uimage)
                        }
                } 
            }.padding(.horizontal)
        }.padding(10)
    }
    
    func doIdentify() {
        if cameraCancel {
            cameraCancel = false
        } else {
            if !selectedImages.isEmpty {
                processingTask?.cancel()
                processingTask = Task {
                    processing = true
                    await identifySelectedImages()
                    processing = false
                }
            } else {
                netManager.displayNames = []
            }
        }
    }
    
    func processPhotos(_ items: [PhotosPickerItem]) async {
        selectedImages.removeAll()
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                selectedImages.append(ImageItem(uimage: img))
            }
        }
        doIdentify()
    }
    
    func identifySelectedImages() async {
        let imgArr: [Data] = Array(selectedImages.prefix(3)).compactMap(\.imgData)
        do {
            try await netManager.identify(project: "all", images: imgArr, organs: nil)
            if let response = netManager.netResponse, !response.results.isEmpty {
                await netManager.saveResult(imgArr)
                
                let skill = netManager.identifyMode ? aiManager.PlantInfoSkill : aiManager.PlantDiseaseSkill
 
                if let bestName = netManager.displayNames.first {
                    if aiManager.aiAvailable {
                        aiManager.currentSkill = skill
                        await aiManager.getResponse(from: bestName)
                        await netManager.updateInfo(newInfo: aiManager.aiReply)
                    }
                }
                
            }
        } catch {
            netManager.displayNames = []
            selectedImages = []
            print(error)
        }
    }
    
}
