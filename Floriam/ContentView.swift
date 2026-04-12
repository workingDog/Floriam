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
    //   @Environment(\.modelContext) private var modelContext
    
    @State private var response: PlantNetResponse?
    
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
            }
            Divider()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages) { imgItem in
                        Image(uiImage: imgItem.uimage)
                    }
                }
            }
            VStack {
                if let names = netManager.netResponse?.results.first?.species.commonNames {
                    ForEach(names, id: \.self) { name in
                        Text(name)
                    }
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
            print("---> imgData1: \(imgData1)\n")
            do {
                try await netManager.identify(project: "all", images: [imgData1], organs: ["flower"])
                // print("---> response: \(netManager.netResponse)")
                netManager.netResponse?.results.forEach { result in
                    print("---> result: \(result)\n")
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    func loadImageData(named name: String, ext: String = "jpeg") -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
}

/*
 
 //        let imgData1: [Data] = selectedImages.compactMap {
 //            $0.uimage.jpegData(compressionQuality: 0.8)
 //        }
         
 //        let imgData: [Data] = selectedImages.compactMap { $0.uimage.pngData() }
         
         print("---> selectedImagesData.first: \(selectedImagesData.first)\n")

 
 .task(id: photoItems) {
     if !photoItems.isEmpty {
         selectedImagesData.removeAll()
         var tempArr: [UIImage] = []
         for item in photoItems {
             if let data = try? await item.loadTransferable(type: Data.self),
                let uiimg = UIImage(data: data) {
                 tempArr.append(uiimg)
                 selectedImagesData.append(data)
             }
         }
         // reduce the size of the images
         let smallerImg = tempArr.compactMap{$0.resizeImageTo(size: CGSize(width: 333, height: 444))}
         // update/onChange selectedImages only once
         selectedImages = smallerImg.map{ImageItem(uimage: $0)}
         photoItems.removeAll()
         
         await identifySelectedImages()
     }
 }
 
 
//        .task {
//
//    //        await netManager.checkStatus()
//
//            if let imgData1: Data = loadImageData(named: "image_1"),
//               let imgData2: Data = loadImageData(named: "image_2"){
//                do {
//                    try await netManager.identify(project: "all", images: [imgData1, imgData2], organs: ["flower", "leaf"])
//        //            print("---> response: \(netManager.netResponse)")
//
//                    netManager.netResponse?.results.forEach { result in
//                        print("---> result: \(result)\n")
//                    }
//
//                } catch {
//                    print(error)
//                }
//            }
//        }
 
 
 */

