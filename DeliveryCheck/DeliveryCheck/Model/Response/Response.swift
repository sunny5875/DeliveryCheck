//
//  Untitled.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//


struct Response: Codable {
    let data: TrackData
}

struct TrackData: Codable {
    let track: TrackDetails
}

struct TrackDetails: Codable {
    let lastEvent: EventDetails?
    let events: EventData?
}

struct EventDetails: Codable, Equatable, Hashable {
    
    let time: String
    let status: StatusDetails
    let description: String?
}

struct StatusDetails: Codable, Equatable, Hashable {
    let code: String
    let name: String?
}

struct EventData: Codable {
    let edges: [NodeData]
}

struct NodeData: Codable {
    let node: EventDetails
}
