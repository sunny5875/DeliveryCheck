//
//  EditItemStore.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/14/25.
//


import Foundation

import ComposableArchitecture
import WidgetKit
import UIKit



@Reducer
struct EditItemStore {
    init() { }
    
    @ObservableState
    struct State: Equatable {
        var company: DeliveryCompany = .cjlogistics
        var item: Item
        
        var checkNameValid: Bool {
            item.name.count != 0
        }
        var checkTracxkNumberValid: Bool {
             7..<15 ~= item.trackingNumber.count
        }
        var isValid: Bool {
            checkNameValid && checkTracxkNumberValid
        }
        
        init(item: Item) {
            self.item = item
            self.company = .init(rawValue: item.carrierId) ?? .cjlogistics
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case didTapPasteButton
        
        case didTapConfirmButton
        case editCompleted(Item)
    }
    
    @Dependency(\.swiftData) var context
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .didTapPasteButton:
                state.item.trackingNumber = UIPasteboard.general.string ?? ""
                return .none
                
            case .didTapConfirmButton:
                guard state.isValid else { return .none }
                return .run { [state = state] send in
                    let newItem = state.item
                    newItem.carrierId = state.company.rawValue
                    newItem.carrierCompany = state.company.name
                    try? editItem(new: newItem)
                    await send(.editCompleted(newItem))
                }
                
            case .editCompleted(_):
                return .none
            }
        }
    }
    
    private func editItem(new: Item) throws {
        try context.edit(new)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}
