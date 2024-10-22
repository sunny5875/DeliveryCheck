//
//  Item.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var carrierId: String
    var state: String
    @Attribute(.unique) var trackingNumber: String
    
    init(carrierId: String, state: String, trackingNumber: String) {
        self.carrierId = carrierId
        self.state = state
        self.trackingNumber = trackingNumber
    }
}


extension Item {
    var statusTitle: String {
        switch state {
        case "IN_TRANSIT": "배송중"
        case "OUT_FOR_DELIVERY": "배송 완료"
        default: "배송준비중"
        }
    }
}
