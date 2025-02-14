//
//  DetailItemView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import WebKit

import ComposableArchitecture



struct DetailItemView: View {
    @Bindable var store: StoreOf<DetailItemStore>
    
    var body: some View {
        NavigationView {
            List {
                Section(store.item.name) {
                    header
                }
                Section("배송 현황") {
                    if store.eventList.isEmpty {
                        Text("아직 배송이 진행되지 않았어요!")
                            .font(.caption)
                        
                    } else {
                        VStack(spacing: 0) {
                            Spacer(minLength: 32)
                            
                            ForEach(store.eventList, id: \.self) { item in
                                cell(item, isLast: store.eventList.last == item)
                            }
                            .padding(.horizontal, 16)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle(store.item.name)
        .toolbarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { store.send(.didTapBackButton) }) {
                    Label("뒤로가기", systemImage: "chevron.backward")
                }
                .tint(Color.black)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { store.send(.didTapEditButton) }) {
                    Label("수정", systemImage: "square.and.pencil")
                }
                .tint(Color.black)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { store.send(.didTapDeleteButton) }) {
                    Label("삭제", systemImage: "trash")
                }
                .tint(Color.black)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(item: $store.scope(state: \.editItem, action: \.editItem)) { store in
            EditItemVIew(store: store)
        }
        .sheet(isPresented: $store.isShowWebView) {
            if let url = store.url {
                WebView(url: url)
            } else {
                EmptyView()
            }
        }
    }
    
    
    var header: some View {
        VStack(spacing: 12) {
            Text(store.item.statusTitle)
                .font(.title)
                .bold()
                .padding(.vertical, 12)
            
            HStack(spacing: 4) {
                Text("운송장 번호")
                    .font(.caption)
                
                Spacer()
                
                
                Button(action: {
                    UIPasteboard.general.string = store.item.trackingNumber
                }) {
                    Text(store.item.trackingNumber)
                        .font(.caption)
                        .bold()
                        .underline(color: Color.blue)
                }
            }
            HStack(spacing: 4) {
                Text("배송사")
                    .font(.caption)
                
                Spacer()
                
                Text(store.item.carrierCompany)
                    .font(.caption)
                    .bold()
            }
            Button(action: {
                store.send(.didTapShowWebView)
            }) {
                Text("실시간으로 보고 싶다면?")
                    .font(.caption)
                    .underline(color: Color.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }
    
    func cell(_ item: EventDetails, isLast: Bool) -> some View {
        VStack {
            HStack {
                VStack(spacing: 2) {
                    
                    Rectangle()
                        .frame(width: 1, height: 24)
                        .foregroundStyle(Color.gray.opacity(0.2))
                    
                    Circle()
                        .frame(width: 8)
                        .foregroundStyle(isLast ? Color.blue : Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .frame(width: 1, height: 24)
                        .foregroundStyle(isLast ? Color.blue : Color.gray.opacity(0.2))
                }
                Text(formatDateString(item.time) ?? "")
                    .font(.caption)
                    .bold()
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.status.name ?? "-")
                        .font(.caption)
                        .bold()
                    Text(item.description ?? "-")
                        .font(.caption)
                }
                Spacer()
            }
            
            
        }
    }
    
    
    func formatDateString(_ dateString: String) -> String? {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.dateFormat = "M월 d일\nHH시 mm분"
        
        return outputFormatter.string(from: date)
    }
}


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
