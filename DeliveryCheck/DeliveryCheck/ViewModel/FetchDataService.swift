//
//  FetchDataService.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import SwiftData
import WidgetKit

final class FetchDataService {
    init() {}
    
    func fetchStatus(item: Item) async throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "apis.tracker.delivery"
        urlComponents.path = "/graphql"
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("TRACKQL-API-KEY 45458ld9m1fv5m12m660qs0jad:b808nhsv4va953s95k4r56hq86b45j6hcitch9f9n3rqg6ug2tn", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")


        let body = [
            "query": """
                   query Track($carrierId: ID!, $trackingNumber: String!) {
                       track(carrierId: $carrierId, trackingNumber: $trackingNumber) {
                           lastEvent {
                               time
                               status {
                                   code
                               }
                           }
                       }
                   }
                   """,
             "variables": [
                 "carrierId": item.carrierId,
                 "trackingNumber": item.trackingNumber
             ]
        ] as [String: Any]

        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: sessionConfig)

        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            do {
                let json = try JSONDecoder().decode(Response.self, from: data)
                print(json)
                if item.state !=  json.data.track.lastEvent.status.code {
                    item.state = json.data.track.lastEvent.status.code
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } catch {
                print("Error parsing JSON response: \(error.localizedDescription)")
                throw error
            }
        } else {
            print("Server responded with error. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        }
    }
}
