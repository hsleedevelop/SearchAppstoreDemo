//
//  MatchesViewModel.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

final class MatchesViewModel: ViewModelType {
    
    //MARK: * Main Logic --------------------
    func transform(input: Input) -> Output {

        let matches = input.matches
        return Output(list: matches.asDriver { _ in Driver.empty() })
    }
}

extension MatchesViewModel {
    
    struct Input {
        let matches: Observable<[String]>
    }
    
    struct Output {
        let list: Driver<[String]>
    }
}
