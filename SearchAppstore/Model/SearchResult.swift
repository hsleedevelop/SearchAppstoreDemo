//
//  SearchResult.swift
//  SearchAppstore
//
//  Created by HS Lee on 05/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit

///검색 결과 모델
struct SearchResult: Decodable, Equatable {
    var term: String?
    var resultCount: Int
    var results: [SearchResultApp]?
    
    enum CodingKeys: String, CodingKey {
        case resultCount = "resultCount"
        case results = "results"
    }
}

func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.term == rhs.term &&
            lhs.results == rhs.results
}
