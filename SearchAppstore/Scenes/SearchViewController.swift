//
//  SearchViewController.swift
//  SearchAppstore
//
//  Created by HS Lee on 05/04/2019.
//  Copyright © 2019 HS Lee LIMITED. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SearchViewController: UIViewController {

    // MARK: - * properties --------------------
    private var disposeBag = DisposeBag()
    private var viewModel = SearchViewModel()
    private var dataSource: RxTableViewSectionedReloadDataSource<TermSectionModel>!
    
    private let boldFont = UIFont.boldSystemFont(ofSize: 17)
    
    private var termRelay = BehaviorRelay<String>(value: "")
    private var searchRelay = PublishRelay<String>()
    private var viewReloadRelay = BehaviorRelay<Void>(value: ())
    
    private var resultVc = SearchResultViewController()
    private lazy var searchController: UISearchController = {
        return UISearchController(searchResultsController: resultVc)
    }()

    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - * Initialize --------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initTable()
        bindViewModel()
    }


    private func initUI() {
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "App Store"
        searchController.dimsBackgroundDuringPresentation = true
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        extendedLayoutIncludesOpaqueBars = true
        
        //init rx
        //검색어 입력
        searchController.searchBar.rx.text.orEmpty
            .filter { [unowned self] in !$0.isEmpty && self.searchController.searchBar.isFirstResponder }
            .distinctUntilChanged()
            .bind(to: termRelay)
            .disposed(by: disposeBag)
        
        //검색 클릭 시
        searchController.searchBar.rx.searchButtonClicked
            .map { [unowned self] in
                self.searchController.searchBar.text ?? ""
            }
            .bind(to: searchRelay)
            .disposed(by: disposeBag)
        
        //검색 캔슬, 검색 입력 종료 시
        Observable.merge(searchController.searchBar.rx.cancelButtonClicked.map { _ in true },
                         searchController.searchBar.rx.textDidEndEditing.map { _ in false },
                         searchController.searchBar.rx.text.orEmpty.map {_ in false }) //검색 시 메인 리스트 바로 갱신하기 위해 추가,
            .throttle(1.2, latest: false, scheduler: MainScheduler.instance) //캔슬버튼, 텍스트 종료 이벤트가 약간의 딜레이로 들어옴.
            .do(onNext: { [unowned self] _ in
                self.viewReloadRelay.accept(())
            })
            .filter { $0 } //차일드 뷰 날릴 지 여부
            .map { [unowned self] _ in (FlowCoordinator.Step.main, self.resultVc) }
            .bind(to: FlowCoordinator.shared.rx.flow)
            .disposed(by: disposeBag)
    }
    
    private func initTable() {
        
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView() //this call table events
        tableView.sectionHeaderHeight = 80
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        dataSource = RxTableViewSectionedReloadDataSource<TermSectionModel>(configureCell: { _, tv, indexPath, term in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell() }
            
            cell.textLabel?.text = term
            cell.textLabel?.textColor = .blue

            return cell
        }, titleForHeaderInSection: { dataSource, section in
            return dataSource[section].header
        })
        
        tableView.rx.itemSelected
            .do(onNext: { [weak self] ip in
                self?.rx.deselectRow.onNext(ip)
                self?.searchController.isActive = true
            })
            .map { [unowned self] in self.dataSource.sectionModels[$0.section].items[$0.row] }
            .subscribe(onNext: { [weak self] in
                self?.searchRelay.accept($0)
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    

    // MARK: - * Main Logic --------------------
    private func bindViewModel() {
        let input = SearchViewModel.Input(viewReload: viewReloadRelay.asObservable(),
                                          term: termRelay.asObservable()) //초기화
        let output = viewModel.transform(input: input)
        
        //output0 - history list
        output.terms
            .map { [TermSectionModel(header: "Recent Terms", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        //output1 = history matching
        output.matches
            .map { [unowned self] in (FlowCoordinator.Step.matches(self.termRelay.value, $0, self.searchRelay), self.resultVc) }
            .drive(FlowCoordinator.shared.rx.flow)
            .disposed(by: disposeBag)
        
        //output2 - fetch and push
        searchRelay.asObservable()
            .do(onNext: { [unowned self] in
                self.searchController.searchBar.text = $0
                self.searchController.searchBar.resignFirstResponder()
            })
            .filter { !$0.isEmpty }
            .delay(0.01, scheduler: MainScheduler.instance)
            
            .map { [unowned self] in (FlowCoordinator.Step.appList($0), self.resultVc) }
            .bind(to: FlowCoordinator.shared.rx.flow)
            .disposed(by: disposeBag)
    }
}

extension SearchViewController: UITableViewDelegate {
}

extension SearchViewController: UISearchBarDelegate {
    
    private func validateKorean(_ text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[가-힣ㄱ-ㅎㅏ-ㅣ\\s]$", options: [])
            if let _ = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, text.count)) {
                return true
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
        return false
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return validateKorean(text) ? true : (range.length == 1 ? true : false)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    //boilerplate function
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResults=\(searchController.searchBar.text)")
    }
}

extension Reactive where Base: SearchViewController {
    
    var deselectRow: Binder<IndexPath> {
        return Binder(self.base) { (view, value) in
            view.tableView.deselectRow(at: value, animated: true)
        }
    }
}
