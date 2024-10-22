////
////  ViewModel.swift
////  DeliveryCheck
////
////  Created by 현수빈 on 10/22/24.
////
//
//import SwiftUI
//import SwiftData
//
//@Observable
//final class ViewModel {
//    private var modelContext: ModelContainer
//    var items: [Item]
//    
//    
//    init(modelContext: ModelContainer) {
//        self.modelContext = modelContext
//        self.items = modelContext.
//    }
//    enum Action {
//        case onAppear
//        case didTapAdd(Item)
//        case didTapDelete(IndexSet)
//    }
//    
//    func reduce(_ action: Action) {
//        switch action {
//        case .onAppear:
//            for item in items {
//                
//            }
//        case .didTapAdd(let new):
//            modelContext.insert(new)
//        case .didTapDelete(let indexSet):
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
//    
//    private func fetchStatus(item: Item) async throws {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = "https"
//        urlComponents.host = "apis.tracker.delivery"
//        urlComponents.path = "/graphql"
//
//        guard let url = urlComponents.url else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("Authorization", forHTTPHeaderField: "TRACKQL-API-KEY 45458ld9m1fv5m12m660qs0jad:b808nhsv4va953s95k4r56hq86b45j6hcitch9f9n3rqg6ug2tn")
//
//        let body = [
//            "query": "query Track(\n  $carrierId: ID!,\n  $trackingNumber: String!\n) {\n  track(\n    carrierId: $carrierId,\n    trackingNumber: $trackingNumber\n  ) {\n    lastEvent {\n      time\n      status {\n        code\n      }\n    }\n  }\n}",
//             "variables": {
//                 "carrierId": item.carrierId,
//                 "trackingNumber": item.trackingNumber
//             }
//        ] as [String: Any]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
//        } catch {
//            print("Error creating JSON data")
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 201 {
//                do {
//                    let json = try JSONDecoder().decode(Response.self, from: data)
//                    print(json)
//                } catch {
//                    print("Error parsing JSON response")
//                }
//            } else {
//                print("Unexpected error")
//            }
//        }
//
//        task.resume()
//    }
//}
