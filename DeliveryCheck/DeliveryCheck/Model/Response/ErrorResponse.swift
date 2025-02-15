//
//  ErrorResponmse.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/15/25.
//

import Foundation


struct ErrorResponse: Decodable {
    let errors: [ErrorData]
    let data: DataTrackData
}

struct ErrorData: Decodable {
    let message: String
    let locations: [LocationData]
    let path: [String]
    let extensions: ExtensionData
}

struct LocationData: Decodable {
    let line: Int
    let column: Int
}

struct ExtensionData: Decodable {
    let code: String
}

struct DataTrackData: Codable {
    let track: TrackDetails?
}
