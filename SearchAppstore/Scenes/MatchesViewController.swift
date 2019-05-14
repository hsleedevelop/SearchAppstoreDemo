//
//  MatchesViewController.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MatchesViewController: UITableViewController {

    //MARK: * properties --------------------
    var term: String?
    var matches: [String]? {
        didSet {
            guard let matches = matches else { return }
            matchesRelay.accept(matches)
        }
    }
    var searchRelay: PublishRelay<String>?
    
    private var disposeBag = DisposeBag()
    private var viewModel = MatchesViewModel()
    private var dataSource: RxTableViewSectionedReloadDataSource<TermSectionModel>!

    private var matchesRelay = PublishRelay<[String]>()

    //MARK: * Initialize --------------------

    override func viewDidLoad() {
        initTable()
        bindViewModel()
    }

    private func initTable() {
        
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView() //this call table events
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dataSource = RxTableViewSectionedReloadDataSource<TermSectionModel>(configureCell: { [unowned self] _, tv, indexPath, item in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell() }
            
            cell.textLabel?.text = item
            cell.textLabel?.textColor = .black
            
            if let term = self.term, !term.isEmpty {//bold 처리
                let tail = item.replacingOccurrences(of: term, with: "")
                cell.textLabel?.set(font: UIFont.boldSystemFont(ofSize: cell.textLabel?.font.pointSize ?? 10), for: tail)
            } else {
                if let font = cell.textLabel?.font {
                    cell.textLabel?.set(font: font, for: item)
                }
            }
            return cell
        })
        
        tableView.rx.itemSelected
            .do(onNext: { [unowned self] ip in
                self.rx.deselectRow.onNext(ip)
            })
            .map { [unowned self] in self.dataSource.sectionModels[$0.section].items[$0.row] }
            .subscribe(onNext: { [unowned self] in
                self.searchRelay?.accept($0) //메인 서치 이벤트 발행.
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    //MARK: * Main Logic --------------------
    private func bindViewModel() {
        
        let input = MatchesViewModel.Input(matches: matchesRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.list
            .map { [TermSectionModel(header: "", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: MatchesViewController {
    
    var deselectRow: Binder<IndexPath> {
        return Binder(self.base) { (view, value) in
            view.tableView.deselectRow(at: value, animated: true)
        }
    }
}
