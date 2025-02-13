//
//  AddItemStore.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/13/25.
//

import Foundation

import ComposableArchitecture
import WidgetKit
import UIKit



@Reducer
struct AddItemStore {
    init() { }
    
    @ObservableState
    struct State: Equatable {
        var company: DeliveryCompany = .cjlogistics
        var newItem: Item = .init(name: "", carrierCompany: "", carrierId: DeliveryCompany.cjlogistics.rawValue, state: "", trackingNumber: "")
        
        var checkNameValid: Bool {
            newItem.name.count != 0
        }
        var checkTracxkNumberValid: Bool {
             7..<15 ~= newItem.trackingNumber.count
        }
        var isValid: Bool {
            checkNameValid && checkTracxkNumberValid
        }
        
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case didTapPasteButton
        
        case didTapConfirmButton
        case addCompleted(Item)
    }
    
    @Dependency(\.swiftData) var context
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .didTapPasteButton:
                state.newItem.trackingNumber = UIPasteboard.general.string ?? ""
                return .none
                
            case .didTapConfirmButton:
                guard state.isValid else { return .none }
                return .run { [state = state] send in
                    let newItem = state.newItem
                    newItem.carrierId = state.company.rawValue
                    newItem.carrierCompany = state.company.name
                    try? addItem(new: newItem)
                    await send(.addCompleted(newItem))
                }
                
            case .addCompleted(_):
                return .none
            }
        }
    }
    
    private func addItem(new: Item) throws {
        try context.add(new)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}
