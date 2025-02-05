//
//  EditItemVIew.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/5/25.
//


import SwiftUI

struct EditItemVIew: View {
    
    @Environment(\.modelContext) var modelContext
    @State private var item: Item
    
    var checkNameValid: Bool {
        item.name.count != 0
    }
    var checkTracxkNumberValid: Bool {
         7..<15 ~= item.trackingNumber.count
    }
    var isValid: Bool {
        checkNameValid && checkTracxkNumberValid
    }
    
    private let onEdit: (Item) -> ()
    
    init (item: Item, onEdit: @escaping (Item) -> ()) {
        self.item = item
        self.onEdit = onEdit
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("물품명") {
                    TextField("1글자 이상의 물품명을 입력하세요.", text: $item.name)
                }
                
                Section("배송사") {
                    Picker(item.carrierCompany, selection: $item.carrierCompany) {
                        ForEach(DeliveryCompany.allCases, id: \.self) { item in
                            Text(item.name)
                        }
                    }
                }
                
                Section("운송장 번호") {
                    TextField("7~15글자의 운송장번호를 입력하세요", text: $item.trackingNumber)
                }
                
            }
            .navigationTitle("수정하기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        guard isValid else { return }
                        onEdit(item)
                    }, label: {
                        Text("완료")
                    })
                    .disabled(!isValid)
                    
                }
                
            }
        }
        
    }
}
