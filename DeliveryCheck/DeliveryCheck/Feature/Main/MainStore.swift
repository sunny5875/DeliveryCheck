//
//  MainStore.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/13/25.
//

import ComposableArchitecture

import SwiftUI
import WidgetKit

@Reducer
struct MainStore {
    init() { }
    
    @ObservableState
    struct State {
        var isLoading = false
        var items: [Item] = []
        var selectedCount: Int? = nil
        var selectedKey: (key: String, value: Int)? = nil
        
        var path = StackState<Path.State>()
        @Presents var addItem: AddItemStore.State?
        
        public init() { }
    }
    
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case onAppearCompleted([Item])
        
        case onChange(Int?, [(key: String, value: Int)])
        
        case refresh
        case refreshFinish([Item])
        
        case didTapAddButton
        
        case didTapDeleteButton(Item)
        case deleteCompleted(Item)
        
        case path(StackActionOf<Path>)
        case addItem(PresentationAction<AddItemStore.Action>)
        
    }
    
    @Dependency(\.swiftData) var context
    @Dependency(\.network) var network
    
    @Reducer
    enum Path {
        case detailItem(DetailItemStore)
    }
    
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state,action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .run { send in
                    do {
                        let items = try context.fetchAll()
                        
                        await send(.onAppearCompleted(items))
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
                
            case let .onAppearCompleted(item):
                withAnimation {
                    state.items = item
                }
                return .none
                
            case .refresh:
                return .run { [state = state] send in
                    var newItems: [Item] = state.items
                    for i in 0..<newItems.count {
                        do {
                            newItems[i] = try await network.fetch(newItems[i])
                        } catch CommonError.invalidResponse {
                            newItems[i].state = "ERROR"
                            continue
                        } catch { continue }
                    }
                    await send(.refreshFinish(newItems))
                }
                
            case let .refreshFinish(items):
                withAnimation {
                    state.items = items
                }
                return .run { send in
                    try? context.save()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                
            case let .didTapDeleteButton(item):
                return .run { send in
                    try? deleteItem(item)
                    await send(.deleteCompleted(item))
                }
                
            case let .deleteCompleted(item):
                withAnimation {
                    if let index = state.items.firstIndex(of: item) {
                        state.items.remove(at: index)
                    }
                }
                return .none
                
            case let .path(.element(id: id, action: .detailItem(.didTapBackButton))):
                state.path.pop(from: id)
                return .none
                
                
            case .didTapAddButton:
                state.addItem = AddItemStore.State()
                return .none
                
            case let .addItem(.presented(.addCompleted(item))):
                withAnimation {
                    state.items.append(item)
                    state.items.sort()
                    state.addItem = .none
                }
                return .none
                
            case let .onChange(new, dict):
                guard let new
                else {
                    state.selectedKey = .none
                    return .none
                }
                var accumulatedCount = 0
                let item = dict.first { (_, count) in
                    accumulatedCount += count
                    return new <= accumulatedCount
                }
                state.selectedKey = item
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$addItem, action: \.addItem) {
            AddItemStore()
        }
    }
    
    private func addItem(new: Item) throws {
        try context.add(new)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deleteItem(_ item: Item) throws {
        try context.delete(item)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    
}
