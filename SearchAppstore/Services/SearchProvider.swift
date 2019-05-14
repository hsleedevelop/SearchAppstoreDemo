//
//  SearchProvider.swift
//  SearchAppstore
//
//  Created by HS Lee on 05/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case error(String)
}

final class SearchProvider {
    enum SearchAPI {
        case search(String)
        
        var url: URL? {
            var urlString: String?
            switch self {
            case let .search(term):
                //urlString = "https://itunes.apple.com/search?term=\(term)&entity=software"
                urlString = "https://itunes.apple.com/search?term=\(term)&entity=software&country=KR&limit=20"
            }
            
            return URL(string: urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        }
    }
    
    static let shared = SearchProvider()
    
    // MARK: - * properties --------------------
    func search(_ term: String) -> Observable<SearchResult> {
        
        guard let url = SearchAPI.search(term).url else {
            return Observable.error(NetworkError.error("잘못된 URL입니다."))
        }
        
        //or -> URLSession.shared.rx.json(request: request)
        return Observable.create { observer in
            
            let request = NSMutableURLRequest(url: url)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let result = try decoder.decode(SearchResult.self, from: data ?? Data())                    
                    observer.onNext(result)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

