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

import ComposableArchitecture

struct MainView: View {
    @Namespace var namespace
    @Bindable var store: StoreOf<MainStore>
    
    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: \.path)
        ) {
            NavigationView {
              ZStack(alignment: .bottomTrailing) {
                Group {
                  if store.items.isEmpty {
                    emptyContet
                  } else {
                    List {
                      chart
                      content
                      description
                    }
                  }
                }
                .navigationTitle("배송체크")
                .navigationBarBackButtonHidden(true)
                
                if store.items.count < Int.maxCount {
                  plusButton
                        .padding(12)
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                }
              }
            }
            .sheet(item: $store.scope(state: \.addItem, action: \.addItem)) { store in
                AddNewItemView(store: store)
            }
            .onAppear {
                store.send(.onAppear, animation: .default)
            }
            .refreshable {
                store.send(.refresh, animation: .default)
            }
            
        } destination: { store in
            switch store.case {
            case .detailItem(let store):
                DetailItemView(store: store)
            }
            
        }
    }
    
    private var plusButton: some View {
        Button(action: {
            store.send(.didTapAddButton, animation: .default)
        }) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(12)
                .foregroundStyle(Color("customWhite"))
                .background(Color("customBlack"))
                .clipShape(Circle())
                .contentShape(Circle())
                .offset(x: -32, y: -16)
                .shadow(radius: 4)
        }
    }
    
    private var emptyContet: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("등록한 배송물품이 없습니다!")
                .font(.headline)
            Text("플러스 버튼을 눌러 최대 \(Int.maxCount)개까지 배송물품을 추가할 수 있습니다.")
                .font(.caption)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var content: some View {
        let dict = store.items.reduce(into: [String: [Item]]()) { result, item in
            result[item.state, default: []].append(item)
        }.sorted(by: { $0.key.statusCode < $1.key.statusCode })
        
        ForEach(dict, id: \.key) { (key, value) in
            Section("\(key.statusTitle)") {
                ForEach(value, id: \.id) { item in
                    
                    NavigationLink(
                        state: MainStore.Path.State.detailItem(DetailItemStore.State(item: item))
                    ) {
                        cell(item)
                            .swipeActions(edge: .trailing) {
                                Button("삭제", role: .destructive) {
                                    store.send(.didTapDeleteButton(item), animation: .default)
                                }
                            }
                    }
                    
                }
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
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(item.color, lineWidth: 1)
                }
        }
    }
    
    
    @ViewBuilder
    private var chart: some View {
        Section("\((store.items.count))개의 배송체크") {
            VStack(spacing: 16) {
                let dict = store.items.reduce(into: [String: Int]()) { result, item in
                    result[item.state, default: 0] += 1
                }.sorted(by: { $0.key.statusCode < $1.key.statusCode })
                
                Chart(dict, id: \.key) { (key, value) in
                    SectorMark(
                        angle: .value(key, value),
                        innerRadius: .ratio(0.5),
                        outerRadius: store.selectedKey?.key == key ? 120 : 110,
                        angularInset: 2
                    )
                    .cornerRadius(8)
                    .foregroundStyle(by: .value("종류", key.statusTitle))
                    .opacity(store.selectedKey == nil || store.selectedKey?.key == key ? 1 : 0.3)
                }
                .chartLegend(.visible)
                .chartAngleSelection(value: $store.selectedCount)
                .onChange(of: store.selectedCount, initial: false) {old, new in
                    store.send(.onChange(new, dict))
                }
                .chartBackground { proxy in
                    VStack(spacing: 2) {
                        Text(store.selectedKey?.key.statusTitle ?? "총 물품 수")
                            .font(.caption)
                            .foregroundStyle(.gray)
        
                        Text("\(store.selectedKey?.value ?? store.items.count)개")
                            .font(.caption)
                            .bold()
                    }
                    .matchedGeometryEffect(id: "chart", in: namespace)
                }
                .frame(height: 250)
            }
        }
    }
    
    @ViewBuilder
    private var description: some View {
        if store.items.count == Int.maxCount {
            Text("최대 \(Int.maxCount)개까지 배송물품을 추가할 수 있습니다.")
                .font(.caption)
                .foregroundStyle(Color.gray)
        } else {
            EmptyView()
        }
    }
    
}
