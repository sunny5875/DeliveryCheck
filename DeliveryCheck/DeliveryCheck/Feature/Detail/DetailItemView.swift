//
//  DetailItemView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import WebKit
import WidgetKit

import ComposableArchitecture

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
    
//    @Binding var path: [Item]
//    @Environment(\.modelContext) var modelContext
//    @State private var isEdit = false
//    @State private var isDelete = false
//    let item: Item
    
    @Bindable var store: StoreOf<DetailItemStore>
    
    var body: some View {
        VStack {
            if let url = store.url {
                WebView(url: url)
                    .navigationTitle(store.item.name)
                .toolbarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            store.send(.didTapBackButton)
                        }) {
                            Label("뒤로가기", systemImage: "chevron.backward")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { store.send(.didTapEditButton) }) {
                            Label("수정", systemImage: "pencil")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { store.send(.didTapDeleteButton) }) {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $store.isEdit) {
            EditItemVIew(
                item: store.item,
                onEdit: { new in
                    store.send(.didTapEditConfirmButton(new))
                }
            )
        }
    }
    
}
