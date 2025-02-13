//
//  AddNewItemView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI

import ComposableArchitecture

struct AddNewItemView: View {
    
    @Bindable var store: StoreOf<AddItemStore>

    
    var body: some View {
        NavigationView {
            Form {
                Section("물품명") {
                    TextField("1글자 이상의 물품명을 입력하세요.", text: $store.newItem.name)
                }
                
                Section("배송사") {
                    Picker(store.company.name, selection: $store.company) {
                        ForEach(DeliveryCompany.allCases, id: \.self) { item in
                            Text(item.name)
                        }
                    }
                }
                
                Section("운송장 번호") {
                    HStack {
                        TextField(
                            "7~15글자의 운송장번호를 입력하세요",
                            text: $store.newItem.trackingNumber
                        )
                        Button("붙여넣기") {
                            store.send(.didTapPasteButton)
                        }
                        
                    }
                }
                
            }
            .navigationTitle("등록하기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        store.send(.didTapConfirmButton)
                    }, label: {
                        Text("완료")
                    })
                    .disabled(!store.isValid)
                    
                }
                
            }
        }
        
    }
}
