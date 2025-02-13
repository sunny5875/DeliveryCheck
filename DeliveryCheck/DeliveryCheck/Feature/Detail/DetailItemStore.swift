//
//  DetailItemStore.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/13/25.
//

import Foundation

import ComposableArchitecture
import WidgetKit



@Reducer
struct DetailItemStore {
    init() { }
    
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var item: Item
        var isEdit = false
        
        var url: URL? {
            URL(string: "https://link.tracker.delivery/track?client_id=45458ld9m1fv5m12m660qs0jad&carrier_id=\(item.carrierId)&tracking_number=\(item.trackingNumber)")
        }
        
        public init(item: Item) {
            self.item = item
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case didTapBackButton
        
        case didTapEditButton
        case didTapEditConfirmButton(Item)
        case editCompleted(Item)
        
        case didTapDeleteButton
        case deleteCompleted
        
    }
    
    @Dependency(\.swiftData) var context
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .didTapBackButton:
                return .none 
                
            case .didTapEditButton:
                state.isEdit.toggle()
                return .none
                
            case let .didTapEditConfirmButton(item):
                return .run { send in
                    try? editItem(new: item)
                    await send(.editCompleted(item))
                }
                
            case let .editCompleted(item):
                state.isEdit.toggle()
                state.item = item
                return .none
                
            case .didTapDeleteButton:
                return .run { [state = state] send in
                    try? deleteItem(state.item)
                    await send(.deleteCompleted)
                }
                
            case .deleteCompleted:
                return .send(.didTapBackButton)
            }
        }
    }
    
    private func editItem(new: Item) throws {
        try context.edit(new)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deleteItem(_ item: Item) throws {
        try context.delete(item)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}

