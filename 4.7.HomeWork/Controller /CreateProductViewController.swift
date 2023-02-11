//
//  CreateProductViewController.swift
//  4.7.HomeWork
//
//  Created by anjella on 20/1/23.


import UIKit

class CreateProductViewController: UIViewController {
    
    @IBOutlet weak var nameTextFieldq: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
   }
    
    @IBAction private func createTapped(_sender: UIButton) {
        guard !nameTextFieldq.text!.isEmpty,
              !brandTextField.text!.isEmpty,
              !descriptionTextField.text!.isEmpty,
              !categoryTextField.text!.isEmpty,
              Int(priceTextField.text!) != nil else {
            showFillAlert()
            return
        }
        
        
        let productModel = ProductDataModel(
            title: nameTextFieldq.text!,
            description: descriptionTextField.text!,
            brand: brandTextField.text!,
            category: categoryTextField.text!,
            thumbnail: "",
            id: 0,
            price: Int(priceTextField.text!)!,
            stock: 0,
            discountPercentage: 0.0,
            rating: 0.0
        )
        
        configurePostingProductsData(model: productModel)
    }
    
    private func configurePostingProductsData(model: ProductDataModel) {
        NetworkLayer.shared.postProductsData(model: model) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.succesfulPostingDataAlert()
                }
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func showFillAlert() {
        let alertVC = UIAlertController(title: "Error", message: "Вы не заполнили все поля", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
    
    private func succesfulPostingDataAlert() {
        let alert = UIAlertController(title: "Данные отправлены успешно", message: "Спасибо за сотрудничество!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}
