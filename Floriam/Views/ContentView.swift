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
    @Environment(PlantNetManager.self) private var netManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var showPrevious = false
    @State private var processing = false
    
    @State private var selectedImages: [ImageItem] = []
    @State private var selectedImagesData: [Data] = []
    @State private var photoItems: [PhotosPickerItem] = []
    
    @State private var processingTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.3),Color.blue.opacity(0.2),Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                        showPrevious = true
                    } label: {
                        VStack {
                            Image(systemName: "list.clipboard").font(.title2)
                            Text("List").font(.caption)
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
        }
        .fullScreenCover(isPresented: $showCamera, onDismiss: processCamera) {
            CameraView(selectedImages: $selectedImages)
        }
        .fullScreenCover(isPresented: $showPrevious) {
            PrevListView()
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItems)
        .task(id: photoItems) {
            guard !photoItems.isEmpty else { return }
            let items = photoItems
            photoItems = []
            processingTask?.cancel()
            processingTask = Task {
                processing = true
                await processPhotos(items)
                processing = false
            }
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
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            ScrollView(.vertical) {
                VStack {
                    if netManager.uniqueDisplayNames(top: 2).isEmpty {
                        Text("No results")
                    } else {
                        ForEach(netManager.uniqueDisplayNames(top: 2), id: \.self) { name in
                            Text(name)
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
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.horizontal)
        }.padding(10)
    }
    
    func processCamera() {
        selectedImagesData.removeAll()
        var tempArr: [UIImage] = []
        for item in selectedImages {
            if let data = item.uimage.jpegData(compressionQuality: 0.8) ,
               let uiimg = UIImage(data: data) {
                tempArr.append(uiimg)
                selectedImagesData.append(data)
            }
        }
        let smallerImg = tempArr.compactMap {
            $0.resizeImageTo(size: CGSize(width: 333, height: 444))
        }
        selectedImages = smallerImg.map { ImageItem(uimage: $0) }
        Task {
            processing = true
            await identifySelectedImages()
            processing = false
        }
    }
    
    func processPhotos(_ items: [PhotosPickerItem]) async {
        selectedImagesData.removeAll()
        var tempArr: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiimg = UIImage(data: data) {
                tempArr.append(uiimg)
                selectedImagesData.append(data)
            }
        }
        let smallerImg = tempArr.compactMap {
            $0.resizeImageTo(size: CGSize(width: 333, height: 444))
        }
        selectedImages = smallerImg.map { ImageItem(uimage: $0) }
        await identifySelectedImages()
    }
    
    func identifySelectedImages() async {
        // todo multiple images
        if let imgData1: Data = selectedImagesData.first {
//            print("---> imgData1: \(imgData1)\n")
            do {
                try await netManager.identify(project: "all", images: [imgData1], organs: nil)
                // print("---> response: \(netManager.netResponse)")
                if netManager.netResponse?.results.isEmpty == false {
                    netManager.saveResult(selectedImagesData)
                }
            } catch {
                print(error)
            }
        }
        
    }

}
