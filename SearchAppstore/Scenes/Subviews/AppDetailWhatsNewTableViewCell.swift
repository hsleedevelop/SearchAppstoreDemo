//
//  AppDetailWhatsNewTableViewCell.swift
//  SearchAppstore
//
//  Created by HS Lee on 09/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class AppDetailWhatsNewTableViewCell: UITableViewCell, AppPresentable {

    //MARK: * properties --------------------
    var app: SearchResultApp?
    var disposeBag = DisposeBag()

    //MARK: * IBOutlets --------------------
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var releaseNotesLabel: UILabel! {
        didSet {
            releaseNotesLabel.numberOfLines = 3
        }
    }
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    //MARK: * Main Logic --------------------
    func configure(_ app: SearchResultApp) {
        self.app = app
        
        versionLabel.text = "version " + version
        
        releaseDateLabel.isHidden = releaseDate == nil
        releaseDateLabel.text = !releaseDateLabel.isHidden ? releaseDate : ""        
        releaseNotesLabel.text = releaseNotes
        
        if moreButton.isHidden == false {
            let numberOfLines = releaseNotes.lineCount(pointSize: releaseNotesLabel.font.pointSize, fixedWidth: releaseNotesLabel.frame.size.width)
            moreButton.isHidden = numberOfLines <= 3
        }
    }
}

extension Reactive where Base: AppDetailWhatsNewTableViewCell {
    
    var moreClicked: Driver<Bool> {
        return base.moreButton.rx.tap
            .asDriver()
            .map { _ in true }
            .do(onNext: { [weak base] _ in
                base?.releaseNotesLabel.numberOfLines = 0
                base?.moreButton.isHidden = true
            })
    }
}
