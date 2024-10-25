//
//  Item.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import SwiftData

@Model
final class Item: Comparable {
    static func < (lhs: Item, rhs: Item) -> Bool {
        lhs.statusCode < rhs.statusCode
    }
    
    var name: String
    var carrierCompany: String
    var carrierId: String
    var state: String
    var trackingNumber: String
    
    init(name: String, carrierCompany: String, carrierId: String, state: String, trackingNumber: String) {
        self.name = name
        self.carrierCompany = carrierCompany
        self.carrierId = carrierId
        self.state = state
        self.trackingNumber = trackingNumber
    }
}


extension Item {
    
    var statusCode: Int {
        switch state {
        case "AT_PICKUP": 1
        case "IN_TRANSIT", "OUT_FOR_DELIVERY": 2
        case "DELIVERED": 3
        default: 0
        }
    } 
    
    var statusTitle: String {
        switch state {
        case "AT_PICKUP": "🛫 배송 시작"
        case "IN_TRANSIT", "OUT_FOR_DELIVERY": "🚀 배송 중"
        case "DELIVERED": "🎁 배송 완료"
        default: "👀 배송 준비중"
        }
    }
    
    var color: Color {
        switch state {
        case "AT_PICKUP": .blue
        case "IN_TRANSIT", "OUT_FOR_DELIVERY": .green
        case "DELIVERED": .orange
        default: .black
        }
    }
}
