//
//  AppListViewController.swift
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

final class AppListViewController: UITableViewController {

    //MARK: * properties --------------------
    var term: String? {
        didSet {
            guard let term = term else { return }
            searchRelay.accept(term)
        }
    }
    
    private var disposeBag = DisposeBag()
    private var viewModel = AppListViewModel()
    private var dataSource: RxTableViewSectionedReloadDataSource<AppListSectionModel>!

    private var searchRelay = PublishRelay<String>()
    private var noResultsRelay = PublishRelay<String>()
    
    private var dispatchQueue = DispatchQueue.init(label: "io.hsleedevelop.applist.queue", qos: DispatchQoS.default)
    private var workItems = [IndexPath: DispatchWorkItem]()
    
    //MARK: * Initialize --------------------

    override func viewDidLoad() {

        //print("AppListViewController_getRetainCount(self)=\(CFGetRetainCount(self))")
        initTable()
        bindViewModel()
        //print("AppListViewController_getRetainCount(self)=\(CFGetRetainCount(self))")
        
        searchRelay.accept(term ?? "") //최초 로딩 시
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //cancel all items
        self.workItems.forEach { $0.value.cancel() }
    }

    private func initTable() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView() //this call table events
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = 300
        
        tableView.delegate = nil    //tableViewController bug with RxDataSources..
        tableView.dataSource = nil
        
        //set datasource
        dataSource = RxTableViewSectionedReloadDataSource<AppListSectionModel>(configureCell: { _, tv, indexPath, app in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "AppListTableViewCell") as? AppListTableViewCell else { return UITableViewCell() }
            cell.configure(app)
            return cell
        })
        
        //did select row
        tableView.rx.itemSelected
            .do(onNext: { [weak self] ip in
                self?.tableView.deselectRow(at: ip, animated: true)
            })
            .map { [unowned self] in self.dataSource.sectionModels[$0.section].items[$0.row] }
            .map { [unowned self] in (FlowCoordinator.Step.appDetail($0), self) }
            .bind(to: FlowCoordinator.shared.rx.flow)
            .disposed(by: disposeBag)
        
        //prefetching
        tableView.rx.prefetchRows.asObservable()
            .subscribe(onNext: { [weak self] indexPaths in
                for ip in indexPaths {
                    guard ip.row < (self?.dataSource.sectionModels.first?.items.count ?? 0), let workItem = self?.workItems[ip]else {
                        return
                    }
                    self?.dispatchQueue.async(execute: workItem)
                }
            })
            .disposed(by: disposeBag)

        //cancel prefetching
        tableView.rx.cancelPrefetchingForRows.asObservable()
            .subscribe(onNext: { [weak self] indexPaths in
                for ip in indexPaths {
                    if let workItem = self?.workItems[ip] {
                        print("workItem.cancel()")
                        workItem.cancel()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - * Main Logic --------------------
    private func bindViewModel() {
     
        ///make prefetching workItem for screenshots in uitableviewcell
        func nestedGenerateWorkItem(_ app: SearchResultApp) -> DispatchWorkItem {
            return DispatchWorkItem {
                app.screenshots?.enumerated().forEach({ [weak self] offset, screenshotUrl in
                    guard offset < 3, let self = self else { return }
                    ImageProvider.shared.get(screenshotUrl)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                })
            }
        }
        
        let input = AppListViewModel.Input(search: searchRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.result
            .do(onNext: { [weak self] in
                if $0.resultCount <= 0 {
                    self?.noResultsRelay.accept(self?.term ?? "")
                }
            })
            .filter { $0.resultCount > 0 }
            .distinctUntilChanged()
            .do(onNext: { [weak self] result in //make prefetching workItem
                self?.workItems = (result.results ?? []).enumerated().reduce([IndexPath: DispatchWorkItem]()) {
                    var dict = $0
                    dict[IndexPath(item: $1.offset, section: 0)] = nestedGenerateWorkItem($1.element)
                    return dict
                }
                print("result.results?.enumerated().reduce(self?.workItems ?? [:]) \(self?.workItems.count ?? 0)")
            })
            .map { [AppListSectionModel(totalCount: $0.resultCount, items: $0.results ?? [])] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        //no data
        noResultsRelay.asObservable()
            .map { [unowned self] in (FlowCoordinator.Step.noResults($0), self.parent ?? self)  }
            .bind(to: FlowCoordinator.shared.rx.flow)
            .disposed(by: disposeBag)
    }
}
