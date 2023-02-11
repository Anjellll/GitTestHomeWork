//
//  SearchViewController.swift
//  4.7.HomeWork
//
//  Created by anjella on 2/1/23.
//

import UIKit
import RxCocoa
import RxSwift

class SearchViewController: UIViewController {

    @IBOutlet private weak var searchTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private let disposeBag = DisposeBag()
    private var products: Observable<[ProductDataModel]>?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        confugureTableView()
        fetchProducts()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func confugureTableView() {
        searchTableView.register(
            UINib(nibName: "SearchProductTableViewCell", bundle: nil),
            forCellReuseIdentifier: SearchProductTableViewCell.reuseID
        )
        
        searchTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        products?.bind(
            to: searchTableView.rx.items(cellIdentifier: "SearchProductTableViewCell")
        ) { row, datasource, cell in
            guard let cell = cell as? SearchProductTableViewCell else { return }
            cell.configureCellBeforeShowing(phone: datasource)
        }
        .disposed(by: disposeBag)
    }
    
    private func fetchProducts() {
        sleep(5)
        products = NetworkLayer.shared.fetchRxProducts()
    }
    
    private func fetch() {
        NetworkLayer.shared.fetchProductsData { model, error in
            if let error = error {
                print(error)
            }
            
            if let model = model {
                print(model)
            }
        }
        
        NetworkLayer.shared.fetchProductsData { result in
            switch result {
            case .success(let model):
                print(model)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func findProducts(text: String) {
        sleep(5)
        products = NetworkLayer.shared.findRxProducts(text: text)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
}


