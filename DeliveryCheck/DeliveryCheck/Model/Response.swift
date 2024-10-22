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
    let lastEvent: EventDetails
}

struct EventDetails: Codable {
    let time: String
    let status: StatusDetails
}

struct StatusDetails: Codable {
    let code: String
}
