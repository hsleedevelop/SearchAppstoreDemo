//
//  AppDetailViewController.swift
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

final class AppDetailViewController: UIViewController, AppPresentable {

    //MARK: * properties --------------------
    var app: SearchResultApp?
    
    private var disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AppDetailSectionModel>!
    
    private var whatNewMoreRelay = BehaviorRelay<Bool>(value: false)
    private var descriptionMoreRelay = BehaviorRelay<Bool>(value: false)
    
    //MARK: * IBOutlets --------------------

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: * Initialize --------------------

    override func viewDidLoad() {
        initTable()
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
    }
    
    private func initTable() {
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView() //this call table events
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600 //max height for what's new and description
        
        dataSource = RxTableViewSectionedAnimatedDataSource<AppDetailSectionModel>(configureCell: { [weak self] ds, tv, ip, model in
            guard ds.sectionModels.count > ip.section, let self = self else { return UITableViewCell() }
            
            var cell: UITableViewCell?
            
            switch model {
            case let .header(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailHeaderTableViewCell") as? AppDetailHeaderTableViewCell {
                    tcell.configure(item)
                    cell = tcell
                }
            case let .whatsNew(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailWhatsNewTableViewCell") as? AppDetailWhatsNewTableViewCell {
                    tcell.configure(item)
                    tcell.rx.moreClicked //observe more sequence
                        .drive(self.whatNewMoreRelay)
                        .disposed(by: self.disposeBag)
                    
                    cell = tcell
                }
            case let .preview(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailScreenshotsTableViewCell") as? AppDetailScreenshotsTableViewCell {
                    tcell.configure(item)
                    cell = tcell
                }
            case let .description(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailDescriptionTableViewCell") as? AppDetailDescriptionTableViewCell {
                    tcell.configure(item)
                    tcell.rx.moreClicked //observe more sequence
                        .drive(self.descriptionMoreRelay)
                        .disposed(by: self.disposeBag)
                    
                    cell = tcell
                }
            case let .information(item):
                if let tcell = tv.dequeueReusableCell(withIdentifier: "AppDetailInformationCell") as? AppDetailInformationCell {
                    tcell.configure(item)
                    cell = tcell
                }
            }
            
            return cell ?? UITableViewCell()
        }, titleForHeaderInSection: { dataSource, section in
            return dataSource[section].identity == "information" ? "Information" : ""
        })
        
        //TOOD: safari???
//        tableView.rx.itemSelected
//            .do(onNext: { [weak self] ip in
//                self?.tableView.deselectRow(at: ip, animated: true)
//            })
//            .map { [unowned self] in self.dataSource.sectionModels[$0.section].items[$0.row] }
//            .map { (FlowCoordinator.Step.appDetail($0), self)  }
//            .bind(to: FlowCoordinator.shared.rx.flow)
//            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - * Main Logic --------------------
    private func setupRx() {
        
        Driver.just(app)
            .unwrap()
            .map { [weak self] app -> [AppDetailSectionModel] in
                guard let self = self else { return [] }
                let top = [AppDetailSectionModel(items: [.header(app)]),
                           AppDetailSectionModel(items: [.whatsNew(app)]),
                           AppDetailSectionModel(items: [.preview(app)]),
                           AppDetailSectionModel(items: [.description(app)])]
                
                let bottom = [AppDetailSectionModel(items: self.informations.map {.information($0)} )]
                return top + bottom
            }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        Driver.merge(whatNewMoreRelay.asDriver(),
                         descriptionMoreRelay.asDriver())
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension AppDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        func nestedCalculateHeight(_ text: String, topMargin top: CGFloat) -> CGFloat {
            
            let width = UIScreen.main.bounds.size.width - 20 - 20 //label left, right margin
            var numberOfLines = text.lineCount(pointSize: 16, fixedWidth: width) //lineHeight == 16
            let adjustHeight: CGFloat = numberOfLines > 3 ? 5 + 28 : 0
            
            numberOfLines = numberOfLines > 3 ? 3 : numberOfLines
            return top + CGFloat(numberOfLines * 16) + adjustHeight + 20 //top margin + label height + bottom margin + button height + bottom margin
        }
        
        let section = dataSource.sectionModels[indexPath.section].items[indexPath.row]
        switch section {
        case .header:
            return 220
        case .preview:
            let adjustHeight: CGFloat = 20 + 20 + 20 + 20 //top margin + header label + label margin + bottom margin
            return screenshotSize.height > 0 ? screenshotSize.height + adjustHeight : 0
        case .whatsNew:
            if whatNewMoreRelay.value == false {
                return nestedCalculateHeight(releaseNotes, topMargin: 80)
            }
            return UITableView.automaticDimension
        case .description:
            if descriptionMoreRelay.value == false {
                return nestedCalculateHeight(appDescription, topMargin: 20)
            }
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
}

