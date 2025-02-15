//
//  NetworkService.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

import SwiftUI
import SwiftData
import WidgetKit

import ComposableArchitecture


extension DependencyValues {
    var network: NetworkService {
        get { self[NetworkService.self] }
        set { self[NetworkService.self] = newValue }
    }
}

struct NetworkService {
    var fetch: @Sendable (Item) async throws -> (Item)
    var getAllInfomation: @Sendable (Item) async throws -> [EventDetails]
}

extension NetworkService: DependencyKey {
    public static let liveValue = Self(fetch: { item in
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "apis.tracker.delivery"
        urlComponents.path = "/graphql"
        guard let url = urlComponents.url,
              let apiKey = Bundle.main.infoDictionary?["apiKey"] as? String
        else { return item }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
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
            debugPrint(String(data: data, encoding: .utf8) ?? "")
            do {
                let json = try JSONDecoder().decode(Response.self, from: data)
                debugPrint(json)
                if let code = json.data.track.lastEvent?.status.code, item.state !=  code {
                    item.state = code
                }
                return item
            } catch {
                if let error = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    item.state = "ERROR"
                    throw CommonError.invalidResponse
                } else {
                    debugPrint("Error parsing JSON response:  \(error.localizedDescription)")
                    throw CommonError.networkError
                }
            }
        } else {
            debugPrint("Server responded with error. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw CommonError.networkError
        }
    }, getAllInfomation: { item in
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "apis.tracker.delivery"
        urlComponents.path = "/graphql"
        guard let url = urlComponents.url,
              let apiKey = Bundle.main.infoDictionary?["apiKey"] as? String
        else { return [] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")


        let body = [
            "query": """
                   query Track($carrierId: ID!, $trackingNumber: String!) {
                   track(
                       carrierId: $carrierId,
                       trackingNumber: $trackingNumber
                     ) {
                       lastEvent {
                         time
                         status {
                           code
                           name
                         }
                         description
                       }
                       events(last: 10) {
                         edges {
                           node {
                             time
                             status {
                               code
                               name
                             }
                             description
                           }
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
            debugPrint(String(data: data, encoding: .utf8) ?? "")
            do {
                let json = try JSONDecoder().decode(Response.self, from: data)
                debugPrint(json)
                if let code = json.data.track.lastEvent?.status.code, item.state !=  code {
                    item.state = code
                }
                return json.data.track.events?.edges.map { $0.node } ?? []
            } catch {
                if let error = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    item.state = "ERROR"
                    throw CommonError.invalidResponse
                } else {
                    debugPrint("Error parsing JSON response:  \(error.localizedDescription)")
                    throw CommonError.networkError
                }
            }
        } else {
            debugPrint("Server responded with error. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw CommonError.networkError
        }
    }
    )
}
