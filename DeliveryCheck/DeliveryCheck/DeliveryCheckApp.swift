//
//  DeliveryCheckApp.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import SwiftData

@main
struct DeliveryCheckApp: App {
    @State var isSplashView = true
    

    var body: some Scene {
        WindowGroup {
            if isSplashView {
                LaunchScreenView()
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            isSplashView = false
                        }
                    }
            } else {
                ContentView()
            }
        }
        .modelContainer(ModelContainer.sharedModelContainer)
    }
}

