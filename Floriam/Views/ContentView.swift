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
    @State private var selectedImages: [ImageItem] = []
    @State private var selectedImagesData: [Data] = []
    @State private var photoItems: [PhotosPickerItem] = []
    
    @State private var processingTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            HStack {
                Button("Camera") {
                    showCamera = true
                }
                Button("Photos") {
                    showPhotoPicker = true
                }
            }.padding(10)
            Divider()
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                    horizontalImagesView
                        .frame(height: geo.size.height * 2.0 / 3.0)
                    Divider()
                    verticalResultsView
                        .frame(height: geo.size.height / 3)
                }
            }
            Spacer()
        }
        .buttonStyle(.borderedProminent)
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(selectedImages: $selectedImages)
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItems)
        .task(id: photoItems) {
            guard !photoItems.isEmpty else { return }
            let items = photoItems
            photoItems = []
            processingTask?.cancel()
            processingTask = Task {
                await processPhotos(items)
            }
        }
        .onAppear {
            netManager.setContext(modelContext)
        }
    }

    @ViewBuilder
    var verticalResultsView: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(netManager.topResults(top: 2)) { result in
                    Text(result.species.scientificName ?? "")
                    if let names = result.species.englishNames {
                        ForEach(names, id: \.self) { name in
                            Text(name)
                        }
                    }
                    Divider()
                }
            }
            .padding(10)
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
        if let imgData1: Data = selectedImagesData.first {
//            print("---> imgData1: \(imgData1)\n")
            do {
                try await netManager.identify(project: "all", images: [imgData1], organs: nil)
                // print("---> response: \(netManager.netResponse)")
//                netManager.netResponse?.results.forEach { result in
//                    print("---> result: \(result)\n")
//                }
            } catch {
                print(error)
            }
        }
        
    }

}
