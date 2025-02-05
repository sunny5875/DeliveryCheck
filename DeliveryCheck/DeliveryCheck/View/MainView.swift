//
//  MainView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import SwiftData
import WidgetKit
import Charts

struct MainView: View {
    @State private var path = [Item]()
    @Query(sort: \Item.name) var items: [Item]
    @Environment(\.modelContext) var modelContext
    @State private var isAdd = false
    private let service = FetchDataService()

    

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if items.isEmpty {
                    emptyContet
                } else {
                    List {
                        chart
                        content
                    }
                    .refreshable {
                        for item in items {
                            try? await service.fetchStatus(item: item)
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                }
            }
            .navigationTitle("배송체크")
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: Item.self) {
                DetailItemView(path: $path, item: $0)
                    .environment(\.modelContext, modelContext)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { deleteCompletedItem()}) {
                        Text("정리")
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if items.count < 10 {
                    plusButton
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
    
    private var plusButton: some View {
        
        Button(action: { isAdd.toggle()}) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(12)
                .foregroundStyle(Color.white)
                .background(Color.blue)
                .clipShape(Circle())
                .offset(x: -32, y: -16)
                .shadow(radius: 4)
        }
    }
    
    private var emptyContet: some View {
        VStack(spacing: 16) {
            Text("등록한 배송물품이 없습니다!")
                .font(.headline)
            Text("플러스 버튼을 눌러 최대 10개까지 배송물품을 추가할 수 있습니다.")
                .font(.caption)
        }
    }
    
    private var content: some View {
        Section("배송물품 목록") {
            ForEach(items) { item in
                NavigationLink(value: item, label: { cell(item) })
            }
            .onDelete(perform: deleteItems)
            .task {
                for item in items {
                    try? await service.fetchStatus(item: item)
                }
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    private func cell(_ item: Item) -> some View {
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
    
    
    @ViewBuilder
    private var chart: some View {
        Section("\((items.count))개의 배송체크") {
            HStack {
                let dict = items.reduce(into: [String: Int]()) { result, item in
                    result[item.state, default: 0] += 1
                }
                
                Chart(dict.sorted(by: { $0.key < $1.key }), id: \.key) { (key, value) in
                    SectorMark(
                        angle: .value(
                            Text(verbatim: key),
                            value
                        ),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .cornerRadius(5)
                    .foregroundStyle(
                        by: .value(
                            Text(verbatim: "\(key.statusTitle)(\(value))"),
                            "\(key.statusTitle)(\(value))"
                        )
                    )
                }
                .chartLegend(alignment: .top, spacing: 18)
                .frame(height: 200)
                
            }
        }
    }
    
}


extension MainView {
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
            }
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func deleteCompletedItem() {
        withAnimation {
            for item in items where item.statusCode == 3 {
                modelContext.delete(item)
            }
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
