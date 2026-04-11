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
    @State private var photoItems: [PhotosPickerItem] = []
    
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
            Spacer()
        }
        .buttonStyle(.borderedProminent)
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(selectedImages: $selectedImages)
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItems)
        .task(id: photoItems) {
            if !photoItems.isEmpty {
                var tempArr: [UIImage] = []
                for item in photoItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiimg = UIImage(data: data) {
                        tempArr.append(uiimg)
                    }
                }
                // reduce the size of the images
                let smallerImg = tempArr.compactMap{$0.resizeImageTo(size: CGSize(width: 333, height: 444))}
                // update/onChange selectedImages only once
                selectedImages = smallerImg.map{ImageItem(uimage: $0)}
                photoItems.removeAll()
            }
        }
        .task {

//            await netManager.checkStatus()
//            
//            if let imgData1: Data = loadImageData(named: "image_1"),
//               let imgData2: Data = loadImageData(named: "image_2"){
//                do {
//                    let response = try await netManager.identify(project: "all", images: [imgData1, imgData2], organs: ["flower", "leaf"])
//                    print("---> response: \(response)")
//                } catch {
//                    print(error)
//                }
//            }
        }
        
    }
    
    func loadImageData(named name: String, ext: String = "jpeg") -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
}
