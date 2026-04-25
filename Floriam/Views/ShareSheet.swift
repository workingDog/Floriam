//
//  ShareSheet.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/25.
//
import SwiftUI


struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
