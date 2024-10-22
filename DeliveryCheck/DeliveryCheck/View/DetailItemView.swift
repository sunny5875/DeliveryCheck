//
//  DetailItemView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}


struct DetailItemView: View {
    
    let item: Item
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: "https://link.tracker.delivery/track?client_id=45458ld9m1fv5m12m660qs0jad&carrier_id=\(item.carrierId)&tracking_number=\(item.trackingNumber)")!)
        }
    }
}
