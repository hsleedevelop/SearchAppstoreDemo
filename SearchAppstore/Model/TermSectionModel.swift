//
//  TermSectionModel.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import RxDataSources


struct TermSectionModel {
    var header: String
    var items: [String]
}

extension TermSectionModel: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = String
    
    var identity: Identity {
        return header
    }
    
    init(original: TermSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

