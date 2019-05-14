//
//  FlowCoordinator.swift
//  SearchAppstore
//
//  Created by HS Lee on 06/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

///플로우 제어
final class FlowCoordinator: ReactiveCompatible {
    static let shared = FlowCoordinator()
    
    enum Step: ReactiveCompatible {
        case main
        case matches(String, [String], PublishRelay<String>)
        case appList(String)
        case appDetail(SearchResultApp)
        case noResults(String)
        
        var identifier: String {
            switch self {
            case .main:
                return "SearchViewController"
            case .matches:
                return "MatchesViewController"
            case .appList:
                return "AppListViewController"
            case .appDetail:
                return "AppDetailViewController"
            case .noResults:
                return "NoResultsViewController"
            }
        }
        
        func load(parentViewController parentVc: UIViewController) {
            
            ///페어런트에 차일드를 등록함.
            func nestedAddViewController(_ parent: UIViewController, _ child: UIViewController) {
                guard child.parent == nil else { return }
                
                parent.children.first?.removeFromParent()
                
                parent.addChild(child)
                parent.view.addSubview(child.view)
                child.view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                child.didMove(toParent: parent)
            }
            
            switch self {
            case .main:
                parentVc.children.forEach { vc in
                    vc.removeFromParent()
                }
            case let .matches(term, matches, relay):
                if let childVc = (parentVc.children.filter { $0 is MatchesViewController }.first ?? self.viewController()) as? MatchesViewController {
                    childVc.term = term
                    childVc.matches = matches
                    childVc.searchRelay = relay
                    
                    nestedAddViewController(parentVc, childVc)
                }
            case let .appList(term):
                if let childVc = (parentVc.children.filter { $0 is AppListViewController }.first ?? self.viewController()) as? AppListViewController {
                    childVc.term = term
                    
                    nestedAddViewController(parentVc, childVc)
                }
            case let .appDetail(app):
                if let childVc = self.viewController() as? AppDetailViewController {
                    childVc.app = app
                    
                    if let navigationController = parentVc.navigationController ?? parentVc.presentingViewController?.navigationController {
                        navigationController.pushViewController(childVc, animated: true)
                    }
                }
            case let .noResults(term):
                if let childVc = self.viewController() as? NoResultsViewController {
                    childVc.term = term
                    
                    nestedAddViewController(parentVc, childVc)
                }
            }
        }
        
        ///뷰 컨트롤러 generate
        private func viewController() -> UIViewController? {
            return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: self.identifier)
        }
    }
}

extension Reactive where Base: FlowCoordinator {
    
    var flow: Binder<(FlowCoordinator.Step, UIViewController)> {
        return Binder(self.base) { _, value in
            value.0.load(parentViewController: value.1)
        }
    }
}
