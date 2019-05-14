//
//  AppListSectionModel.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import RxDataSources

struct AppListSectionModel {
    var totalCount: Int
    var items: [SearchResultApp]
}

extension AppListSectionModel: SectionModelType {
    typealias Item = SearchResultApp
    
    init(original: AppListSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

