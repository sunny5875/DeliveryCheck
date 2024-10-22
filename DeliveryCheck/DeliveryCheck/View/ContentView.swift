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
            List {
                ForEach(items) { item in
                    NavigationLink {
                        DetailItemView(item: item)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                    Text("운송장번호: \(item.trackingNumber)(\(item.carrierCompany))")
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            Text(item.statusTitle)
                                .foregroundStyle(.white)
                                .font(.caption)
                                .padding(8)
                                .background(Color.black)
                                .cornerRadius(4)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .refreshable {
                for item in items {
                    try? await service.fetchStatus(item: item)
                }
            }
            .onDisappear {
                try? modelContext.save()
            }
            .navigationTitle("택배췌크")
            .task {
                for item in items {
                    try? await service.fetchStatus(item: item)
                }
            }
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
