//
//  AddNewItemView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI

struct AddNewItemView: View {
    
    @State private var newItem: Item = .init(carrierId: DeliveryCompany.cjlogistics.rawValue, state: "", trackingNumber: "")
    
    private let onAdd: (Item) -> ()
    
    init (onAdd: @escaping (Item) -> ()) {
        self.onAdd = onAdd
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("배송사를 선택하세요") {
                    Picker(newItem.carrierId, selection: $newItem.carrierId) {
                        ForEach(DeliveryCompany.allCases, id: \.self) { item in
                            VStack {
                                Text(item.name)
                                Text(item.tel ?? "-")
                            }
                        }
                    }
                }
                
                TextField("운송장번호를 입력하세요", text: $newItem.trackingNumber)
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        onAdd(newItem)
                    }, label: {
                        Text("추가")
                    })
                }
            }
        }
        
    }
}
