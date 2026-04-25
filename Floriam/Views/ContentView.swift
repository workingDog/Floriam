//
//  ContentView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//

import SwiftUI
import SwiftData
import PhotosUI


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PlantNetManager.self) private var netManager
    
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var processing = false
    
    @State private var selectedImages: [ImageItem] = []
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var sharedImage: ImageItem?
    
    @State private var processingTask: Task<Void, Never>?
    

    var body: some View {
        ZStack {
            backGradient.ignoresSafeArea()
            
            VStack {
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
                        showHistory = true
                    } label: {
                        VStack {
                            Image(systemName: "list.clipboard").font(.title2)
                            Text("History").font(.caption)
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
                    Spacer()
                    
//                    Menu {
//                        Button("Settings") {
//                            showSettings = true
//                        }
//                    } label: {
//                        VStack {
//                            Image(systemName: "ellipsis.circle").font(.title2)
//                            Text("More").font(.caption)
//                        }
//                    }
                    
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear").font(.title2)
                    }.tint(.gray)
                }
                .disabled(processing)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(.ultraThinMaterial)
                Divider()
                GeometryReader { geo in
                    VStack(alignment: .leading, spacing: 0) {
                        horizontalImagesView.frame(height: geo.size.height * 2.0 / 3.0)
                        Divider()
                        verticalResultsView.frame(height: geo.size.height / 3)
                    }
                }
                Spacer()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green.opacity(0.8))
        }
        .sheet(item: $sharedImage) { item in
            ShareSheet(items: [item.uimage])
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCamera, onDismiss: doIdentify) {
            CameraView(selectedImages: $selectedImages)
        }
        .fullScreenCover(isPresented: $showHistory) {
            HistoryListView().environment(netManager)
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
                VStack {
                    if netManager.displayNames.isEmpty {
                        Text("No results")
                    } else {
                        ForEach(netManager.displayNames, id: \.self) { name in
#if targetEnvironment(macCatalyst)
                            TextEditor(text: .constant(name))
                                .font(.title3)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
#else
                            Text(name).font(.title3)
                                .textSelection(.enabled)
#endif
                        }
                    }
                }.padding(10)
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
            }
            .padding(.horizontal)
        }.padding(10)
    }
    
    func doIdentify() {
        processingTask?.cancel()
        processingTask = Task {
            processing = true
            await identifySelectedImages()
            processing = false
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
            }
        } catch {
            netManager.displayNames = []
            print(error)
        }
    }
    
}
