//
//  String+.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/6/25.
//

import SwiftUI

extension String {
    
    var statusCode: Int {
        switch self {
        case "AT_PICKUP": 1
        case "IN_TRANSIT", "OUT_FOR_DELIVERY": 2
        case "DELIVERED": 3
        default: 0
        }
    }
    
    var statusTitle: String {
        switch self {
        case "AT_PICKUP": "🛫 배송 시작"
        case "IN_TRANSIT", "OUT_FOR_DELIVERY": "🚀 배송 중"
        case "DELIVERED": "🎁 배송 완료"
        default: "👀 배송 준비중"
        }
    }
    
    var color: Color {
        switch self {
        case "AT_PICKUP": .blue
        case "IN_TRANSIT", "OUT_FOR_DELIVERY": .green
        case "DELIVERED": .orange
        default: .purple
        }
    }
    
}
