//
//  AddNewItemView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI

struct AddNewItemView: View {
    
    @State private var deliveryCompany = DeliveryCompany.cjlogistics
    @State private var newItem: Item = .init(name: "", carrierCompany: "", carrierId: DeliveryCompany.cjlogistics.rawValue, state: "", trackingNumber: "")
    
    private let onAdd: (Item) -> ()
    
    init (onAdd: @escaping (Item) -> ()) {
        self.onAdd = onAdd
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("물품명") {
                    TextField("물품명을 입력하세요", text: $newItem.name)
                }
                
                Section("배송사") {
                    Picker(deliveryCompany.name, selection: $deliveryCompany) {
                        ForEach(DeliveryCompany.allCases, id: \.self) { item in
                            Text(item.name)
                        }
                    }
                }
                
                Section("운송장 번호") {
                    TextField("운송장번호를 입력하세요", text: $newItem.trackingNumber)
                }
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        newItem.carrierId = deliveryCompany.rawValue
                        newItem.carrierCompany = deliveryCompany.name
                        onAdd(newItem)
                    }, label: {
                        Text("완료")
                    })
                }
            }
        }
        
    }
}
