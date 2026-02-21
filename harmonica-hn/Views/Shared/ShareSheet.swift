//
//  ShareSheet.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
#endif