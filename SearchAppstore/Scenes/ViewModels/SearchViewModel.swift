//
//  SearchViewModel.swift
//  SearchAppstore
//
//  Created by HS Lee on 05/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

final class SearchViewModel: ViewModelType {
    
    func transform(input: Input) -> Output {
        print("_getRetainCount(self)=\(CFGetRetainCount(self))")
        //서치 메인, 키워드 입력 시 매핑
        let terms = input.viewReload
            .flatMap { TermsProvider.shared.fetch() }
        
        //서치 메인, 키워드 입력 시 매핑
        let matches = input.term
            .flatMap { term in
                TermsProvider.shared.fetch()
                    .map { terms in
                        terms.filter { $0.contains(term) || term.isEmpty }
                }
            }
        print("_getRetainCount(self)=\(CFGetRetainCount(self))")
        return Output(terms: terms.asDriver { _ in Driver.empty() },
                      matches: matches.asDriver { _ in Driver.empty() })
    }
}

extension SearchViewModel {
    
    struct Input {
        let viewReload: Observable<Void>
        let term: Observable<String>
    }
    
    struct Output {
        let terms: Driver<[String]>
        let matches: Driver<[String]>
    }
}
