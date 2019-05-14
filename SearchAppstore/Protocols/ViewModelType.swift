//
//  ViewModelType.swift
//  SearchAppstore
//
//  Created by HS Lee on 05/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
