//
//  ImageProvider.swift
//  SearchAppstore
//
//  Created by HS Lee on 07/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ImageProvider {

    //MARK: * Singleton --------------------
    static let shared = ImageProvider()
    
    ///cache
    private let imageCache = NSCache<AnyObject, AnyObject>()
    
    private init() {
        imageCache.totalCostLimit = 10 * (1024 * 1024) //10 mega bytes
    }

    
    // MARK: - * Main Business --------------------
    func get(_ urlString: String) -> Observable<UIImage> {
        
        guard let url = URL(string: urlString) else {
            return Observable.error(NetworkError.error("잘못된 URL입니다."))
        }
        
        return Observable.create { observer in
            var task: URLSessionDataTask?
            
            let cachedImage = self.imageCache.object(forKey: urlString as AnyObject) as? UIImage
            if let image = cachedImage {
                observer.onNext(image)
                observer.onCompleted()
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true   //trackActivity 대신 사용.
                }
                task = URLSession.shared.dataTask(with: url) { data, response, error in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    do {
                        if let data = data, let image = UIImage(data: data) {
                            self.imageCache.setObject(image as AnyObject, forKey: urlString as AnyObject)
                            observer.onNext(image)
                        } else {
                            throw NetworkError.error("no image data")
                        }
                    } catch let error {
                        observer.onError(error)
                    }
                    observer.onCompleted()
                }
            }
            task?.resume()
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }

}
