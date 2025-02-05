//
//  DetailItemView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import WebKit
import WidgetKit

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
    @Binding var path: [Item]
    @Environment(\.modelContext) var modelContext
    @State private var isEdit = false
    @State private var isDelete = false
    let item: Item
    
    var url: URL? {
        URL(string: "https://link.tracker.delivery/track?client_id=45458ld9m1fv5m12m660qs0jad&carrier_id=\(item.carrierId)&tracking_number=\(item.trackingNumber)")
    }
    
    var body: some View {
        VStack {
            if let url {
                WebView(url: url)
                .navigationTitle(item.name)
                .toolbarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { path.removeLast() }) {
                            Label("뒤로가기", systemImage: "chevron.backward")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { isEdit.toggle() }) {
                            Label("수정", systemImage: "pencil")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { deleteItem() }) {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isEdit) {
            EditItemVIew(
                item: item,
                onEdit: { new in
                    editItem(new: new)
                    isEdit.toggle()
                }
            )
        }
    }
    
    private func editItem(new: Item) {
        withAnimation {
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        path.removeLast()
    }
}
