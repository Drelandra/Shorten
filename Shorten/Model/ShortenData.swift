//
//  ShortenData.swift
//  Shorten
//
//  Created by Andre Elandra on 16/06/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import Foundation

struct ShortenData: Codable {
    let hashid: String
    let url: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case hashid, url
        case createdAt = "created_at"
    }
}
