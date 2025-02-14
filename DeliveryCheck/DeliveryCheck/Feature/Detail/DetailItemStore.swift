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
        var eventList: [EventDetails] = []
        var isShowWebView: Bool = false
        
        @Presents var editItem: EditItemStore.State?
        
        var url: URL? {
            URL(string: "https://link.tracker.delivery/track?client_id=45458ld9m1fv5m12m660qs0jad&carrier_id=\(item.carrierId)&tracking_number=\(item.trackingNumber)")
        }
        
        public init(item: Item) {
            self.item = item
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        case onAppearFinish([EventDetails])
        
        case didTapBackButton
        
        case didTapEditButton
        
        case didTapDeleteButton
        case deleteCompleted
        
        case didTapShowWebView
        
        case editItem(PresentationAction<EditItemStore.Action>)
        
    }
    
    @Dependency(\.swiftData) var context
    @Dependency(\.network) var network
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .run { [state = state ] send in
                    do {
                        let list = try await network.getAllInfomation(state.item)
                        await send(.onAppearFinish(list))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            case .onAppearFinish(let list):
                state.eventList = list
                return .none
                
            case .didTapBackButton:
                return .none 
                
            case .didTapEditButton:
                state.editItem = EditItemStore.State(item: state.item)
                return .none
                
            case let .editItem(.presented(.editCompleted(item))):
                state.item = item
                state.editItem = .none
                return .none
                
                
            case .didTapDeleteButton:
                return .run { [state = state] send in
                    try? deleteItem(state.item)
                    await send(.deleteCompleted)
                }
                
            case .deleteCompleted:
                return .send(.didTapBackButton)
                
            case .didTapShowWebView:
                state.isShowWebView.toggle()
                return .none
                
            default:
                return .none
            }
        }
        .ifLet(\.$editItem, action: \.editItem) {
            EditItemStore()
        }
    }
    

    private func deleteItem(_ item: Item) throws {
        try context.delete(item)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}

