//
//  DiseaseView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/15.
//
import Foundation
import SwiftUI
import WebKit


struct DiseaseView: View {
    let name: String?
    let description: String?

    @State private var page = WebPage()

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppTheme.backGradient.ignoresSafeArea()
            WebView(page)
            if page.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2.0)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("search for: \(name ?? "")")
        .task(id: name) {
            guard let name else { return }
            page.load(URLRequest(url: plantwiseURL(for: name)))
        }
    }

    func plantwiseURL(for disease: String) -> URL {
        var components = URLComponents(string: "https://plantwiseplusknowledgebank.org/search")!
        components.queryItems = [URLQueryItem(name: "query", value: disease)]
        return components.url!
    }
}

