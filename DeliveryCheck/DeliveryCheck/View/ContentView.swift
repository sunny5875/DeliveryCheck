//
//  ContentView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Query var items: [Item]
    @Environment(\.modelContext) var modelContext
    @State private var isAdd = false
    private let service = FetchDataService()

    var body: some View {
        NavigationView {
            Group {
                if items.isEmpty {
                    emptyContet
                } else {
                    List {
                        content
                    }
                    .refreshable {
                        for item in items {
                            try? await service.fetchStatus(item: item)
                        }
                    }
                }
            }
            .onDisappear {
                try? modelContext.save()
            }
            .navigationTitle("택배췌크")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isAdd.toggle()}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isAdd) {
            AddNewItemView(onAdd: { new in
                addItem(new: new)
                isAdd.toggle()
            })
        }
    }
    
    private var emptyContet: some View {
        VStack(spacing: 16) {
            Text("등록한 배송물품이 없습니다!")
                .font(.headline)
            Text("플러스 버튼을 눌러 추가해보세요!")
                .font(.caption)
        }
    }
    
    private var content: some View {
        ForEach(items) { item in
            NavigationLink {
                DetailItemView(item: item)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .fontWeight(.bold)
                            Text("운송장번호: \(item.trackingNumber)(\(item.carrierCompany))")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    Spacer()
                    Text(item.statusTitle)
                        .foregroundStyle(item.color)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(8)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(item.color, lineWidth: 1)
                        }
                }
            }
        }
        .onDelete(perform: deleteItems)
        .task {
            for item in items {
                try? await service.fetchStatus(item: item)
            }
        }
    }

    private func addItem(new: Item) {
        withAnimation {
            modelContext.insert(new)
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
}
