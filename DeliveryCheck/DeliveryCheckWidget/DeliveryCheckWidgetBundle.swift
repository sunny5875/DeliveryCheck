//
//  DeliveryCheckWidgetBundle.swift
//  DeliveryCheckWidget
//
//  Created by 현수빈 on 10/22/24.
//

import WidgetKit
import SwiftUI

@main
struct DeliveryCheckWidgetBundle: WidgetBundle {
    var body: some Widget {
        DeliveryCheckWidget()
        DeliveryCheckWidgetControl()
        DeliveryCheckWidgetLiveActivity()
    }
}
