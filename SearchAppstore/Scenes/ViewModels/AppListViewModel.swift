//
//  AppListViewModel.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

final class AppListViewModel: ViewModelType {
    
    func transform(input: Input) -> Output {
        
        //검색 요청 시
        let results = input.search
            .do(onNext: { _ in  //trackActivity 대체 가능.
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            })
            .flatMap { term in
                SearchProvider.shared.search(term)
                    .map { (term, $0)  }
                    .catchError { error in
                        print(error.localizedDescription)
                        return .empty() //FIXME: return [] ? >> 에러처리를 하고, 엠티를 날려도 괜찮을 듯,
                }
            }
            .do(onNext: { results in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if results.1.resultCount > 0 {
                    _ = TermsProvider.shared.store(results.0) //결과가 있을 경우만 검색어를 저장함.
                        .subscribe()
                }
            })
            .map { $0.1 }
        
        return Output(result: results.asDriver { _ in Driver.empty() })
    }
}

extension AppListViewModel {
    
    struct Input {
        let search: Observable<String>
    }
    
    struct Output {
        let result: Driver<SearchResult>
    }
}
