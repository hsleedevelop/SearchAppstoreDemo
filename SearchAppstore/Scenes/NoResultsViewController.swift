//
//  NoResultsViewController.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit

final class NoResultsViewController: UIViewController {

    //MARK: * properties --------------------
    var term: String?

    //MARK: * IBOutlets --------------------
    @IBOutlet weak var forLabel: UILabel!
    
    //MARK: * Initialize --------------------

    override func viewDidLoad() {
        self.initUI()
    }

    private func initUI() {
        self.forLabel.text = "for \"\(term ?? "")\""
    }
}

