//
//  LaunchScreenView.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/25/24.
//

import SwiftUI

struct LaunchScreenView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            Text("배송 체크")
                .font(.largeTitle)
                .bold()
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height:  120)
        }
    }
}
