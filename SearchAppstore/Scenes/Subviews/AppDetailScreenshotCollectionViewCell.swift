//
//  AppDetailScreenshotCollectionViewCell.swift
//  SearchAppstore
//
//  Created by HS Lee on 09/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class AppDetailScreenshotCollectionViewCell: UICollectionViewCell { //AppPresentable {

    //MARK: * properties --------------------
    var screenshotUrl: String?
    var disposeBag = DisposeBag()
    
    //MARK: * IBOutlets --------------------
    @IBOutlet weak var screenshotImageView: UIImageView! {
        didSet {
            screenshotImageView.cornerRadius = 10
            screenshotImageView.borderColor = .lightGray
            screenshotImageView.borderWidth = 0.5
            screenshotImageView.contentMode = .scaleAspectFill
        }
    }
    
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    //MARK: * Main Logic --------------------
    func configure(_ screenshotUrl: String) {
        self.screenshotUrl = screenshotUrl
        
        setupRx()
    }
    
    private func setupRx() {
        guard let screenshotUrl = screenshotUrl else {
            return
        }
        
        ImageProvider.shared.get(screenshotUrl)
            .bind(to: self.screenshotImageView.rx.image)
            .disposed(by: disposeBag)
    }
}

