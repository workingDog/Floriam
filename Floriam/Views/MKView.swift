//
//  MKView.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/05/15.
//
import SwiftUI
import Textual


struct MKView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView {
                StructuredText(markdown: text)
                    .textual.textSelection(.enabled)
                    .textual.structuredTextStyle(.gitHub)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }
}
