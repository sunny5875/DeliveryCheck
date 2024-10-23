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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

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
        .modelContainer(sharedModelContainer)
    }
}

struct LaunchScreenView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIStoryboard(name: "Launch Screen", bundle: nil).instantiateInitialViewController()!
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
