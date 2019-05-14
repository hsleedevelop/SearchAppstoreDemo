//
//  AppDetailInformationCell.swift
//  SearchAppstore
//
//  Created by HS Lee on 09/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class AppDetailInformationCell: UITableViewCell {//, AppPresentable {

    //MARK: * properties --------------------
    var disposeBag = DisposeBag()   //URL 오픈 시 사용할 수도..
    
    //MARK: * IBOutlets --------------------
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    
    //MARK: * override --------------------
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    //MARK: * Main Logic --------------------
    func configure(_ info: AppInformationType) {
        subjectLabel.text = info.subject
        contentLabel.text = info.content
    }
}
