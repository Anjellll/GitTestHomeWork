//
//  ViewController.swift
//  4.7.HomeWork
//
//  Created by anjella on 16/1/23.

// (1) Изменить запросы гет на async await

// (2) В верстку подвязать RxSwift
// Все запросы кроме GET поменять на async await
// GET запрос написать на RX

import UIKit
import RxCocoa
import RxSwift

class MainViewController: UIViewController {
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var storeCollectionView: UICollectionView!
    @IBOutlet private weak var productsTableView: UITableView!
    
    
    private let categoryDataArray: [CategoryDataModel] = [
        .init(imageView: UIImage(named: "delivery")!, dataHorizantally: "Delivery"),
        .init(imageView: UIImage(named: "pickup")!, dataHorizantally: "Pickup"),
        .init(imageView: UIImage(named: "catering")!, dataHorizantally: "Catering"),
        .init(imageView: UIImage(named: "curbside")!, dataHorizantally: "Curbside")
    ]
    
    private let storesDatArray: [StoreDataModel] = [
        .init(imageView: UIImage(named: "image1")!, storesName: "Takeaways"),
        .init(imageView: UIImage(named: "image2")!, storesName: "Grocery"),
        .init(imageView: UIImage(named: "image3")!, storesName: "Convenience"),
        .init(imageView: UIImage(named: "image4")!, storesName: "Pharmacy")
    ]
    
    private let disposeBag = DisposeBag()
    private var products: Observable<[ProductDataModel]>?
    
    private let girls = ["Alsu", "Lena"]
    private let boys = ["Omar"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchProducts()
        confugureTableView()
        print(girls.count)
        
//        Task {
//            do {
//                try await fetchProducts()
//            } catch {
//                print("Error")
//            }
//        }
    }
    
    private func confugureTableView() {
        productsTableView.register(
            UINib(nibName: "ProductTableViewCell", bundle: nil),
            forCellReuseIdentifier: ProductTableViewCell.reuseID
        )
        
        productsTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        products?.bind(
            to: productsTableView.rx.items(cellIdentifier: "ProductTableViewCell")
        ) { row, datasource, cell in
            guard let cell = cell as? ProductTableViewCell else { return }
            cell.display(item: datasource)
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
    
    private func configureCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(
            UINib(
                nibName: String(describing: CategoryCollectionViewCell.self),
                bundle: nil),
            forCellWithReuseIdentifier: CategoryCollectionViewCell.reusedID)
        
        storeCollectionView.dataSource = self
        storeCollectionView.delegate = self
        storeCollectionView.register(
            UINib(
                nibName: String(describing: StoreCollectionViewCell.self),
                bundle: nil),
            forCellWithReuseIdentifier: StoreCollectionViewCell.reusedID)
    }
      

    private func deleteTakeaways(by id: Int) {
        NetworkLayer.shared.deleteProductsData(id: id) { result in
            if case .failure(let error) = result {
                print(error.localizedDescription)
            }
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == categoryCollectionView {
            return categoryDataArray.count
        }else{
            return storesDatArray.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CategoryCollectionViewCell",
                for: indexPath) as! CategoryCollectionViewCell
            let data = categoryDataArray[indexPath.row]
            cell.display(item: data, selected: data)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "StoreCollectionViewCell",
                for: indexPath) as! StoreCollectionViewCell
            let data = storesDatArray[indexPath.row]
            cell.display(item: data)
            return cell
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
          layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == categoryCollectionView {
            return CGSize(width: 120, height: 36)
        } else {
            return CGSize(width: 100, height: 130)
        }
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
}

