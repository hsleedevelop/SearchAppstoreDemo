//
//  TermsProvider.swift
//  SearchAppstore
//
//  Created by HS Lee on 05/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import RxSwift

final class TermsProvider {
    static let termsKey = "TERMS"
    static let maxTermsCount = 10
    
    static let shared = TermsProvider()
    private var dispatchQueue = DispatchQueue.init(label: "io.hsleedevelop.terms.queue", qos: DispatchQoS.default)
    private var terms: [String] = []
    
    func store(_ term: String) -> Observable<Bool> {
        
        if let index = terms.firstIndex(where: { $0 == term }) {//이미 저장된 검색어일 경우, 최상위로 올림
            terms.remove(at: index) //해당 검색어를 지워둠.
        }
        
        let count = terms.count >= TermsProvider.maxTermsCount ? TermsProvider.maxTermsCount - 1 : terms.count //최대 검색어 저장 갯수만큼 저장
        terms = [term] + terms[0..<count] //가장 최신을 위로
        
        return Observable.create { observer -> Disposable in
            self.dispatchQueue.sync { [weak self] in
                guard let self = self else { return }
                
                UserDefaults.standard.set(self.terms, forKey: TermsProvider.termsKey)
                if UserDefaults.standard.synchronize() {
                    observer.onNext(UserDefaults.standard.synchronize())
                }
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
    
    ///저장된 검색어 fetch
    func fetch() -> Observable<[String]> {
        return Observable.create { observer -> Disposable in
            self.dispatchQueue.sync { [weak self] in
                guard let self = self else { return }

                if let storedTerms = UserDefaults.standard.array(forKey: TermsProvider.termsKey) as? [String] {
                    self.terms = storedTerms
                }
                observer.onNext(self.terms)
                observer.onCompleted()
            }
            
            return Disposables.create {}
        }
    }
}
