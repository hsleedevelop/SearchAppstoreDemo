//
//  AppDetailDescriptionTableViewCell.swift
//  SearchAppstore
//
//  Created by HS Lee on 09/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class AppDetailDescriptionTableViewCell: UITableViewCell, AppPresentable {

    //MARK: * properties --------------------
    var app: SearchResultApp?
    var disposeBag = DisposeBag()
    
    //MARK: * IBOutlets --------------------
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 3
        }
    }
    @IBOutlet weak var moreButton: UIButton!
    
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    //MARK: * Main Logic --------------------
    func configure(_ app: SearchResultApp) {
        self.app = app
        
        descriptionLabel.text = appDescription

        if moreButton.isHidden == false {
            let numberOfLines = appDescription.lineCount(pointSize: descriptionLabel.font.pointSize, fixedWidth: descriptionLabel.frame.size.width)
            moreButton.isHidden = numberOfLines <= 3
        }
    }

}

extension Reactive where Base: AppDetailDescriptionTableViewCell {
    
    var moreClicked: Driver<Bool> {
        return base.moreButton.rx.tap
            .asDriver()
            .map { _ in true }
            .do(onNext: { [weak base] _ in
                base?.descriptionLabel.numberOfLines = 0
                base?.moreButton.isHidden = true
            })
    }
}
