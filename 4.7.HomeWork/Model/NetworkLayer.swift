//
//  NetworkLayer.swift
//  4.7.HomeWork
//
//  Created by anjella on 20/1/23.


// (1) Изменить запросы гет на async await

// (2) В верстку подвязать RxSwift
// Все запросы кроме GET поменять на async await
// GET запрос написать на RX

import Foundation
import RxSwift


class NetworkLayer {
    
    static let shared = NetworkLayer()
    private init() { }
    
    var baseUrl = URL(string: "https://dummyjson.com/products")!
    let session = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask? = nil
    
   // GET запрос написать на RX
    func fetchRxProducts() -> Observable<[ProductDataModel]> {
        return Observable<[ProductDataModel]>.create { observer in
            self.dataTask = self.session.dataTask(with: self.baseUrl) { data, response, error in
                do {
                    let model = try JSONDecoder().decode(Products.self, from: data!)
                    observer.onNext(model.products)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            self.dataTask?.resume()
            return Disposables.create {
                self.dataTask?.cancel()
            }
        }
    }
    
    func fetchProductsData(completion: @escaping (Result<Products, Error>) -> Void) {
        let request = URLRequest(url: baseUrl)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(Products.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchProductsData(completion: @escaping (Products?, Error?) -> Void) {
        let request = URLRequest(url: baseUrl)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(Products.self, from: data)
                completion(decodedData, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func fetchProducts() async throws -> Products {
        let (data, _) = try await URLSession.shared.data(from: baseUrl)
        return await decodedData(data: data)
    }
    
   
    func decodedData<T: Decodable>(data: Data) async -> T {
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: data)
    }
      
    func decodeData<T: Decodable>(data: Data, completion: @escaping (Result<T, Error>) -> Void) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }
  // search to rx
    func findRxProducts(text: String) -> Observable<[ProductDataModel]> {
        return Observable<[ProductDataModel]>.create { observer in
            let  urlQueryItem = URLQueryItem(name: "q", value: text)
            let request = URLRequest(url: self.baseUrl.appendingPathComponent("search").appending(queryItems: [urlQueryItem]))
            Task {
                let (data, response) = try await URLSession.shared.data(for: request)
                print("Response: \(response)")
                do {
                    let model = try JSONDecoder().decode(Products.self, from: data)
                    observer.onNext(model.products)
                } catch {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                
            }
        }
      
    }
    
    func findProductsData(
        text: String,
        completion: @escaping (Result<Products, Error>) -> Void
    ) {
        let urlQueryItem = URLQueryItem(name: "q", value: text)
        
        let request = URLRequest(url: baseUrl.appendingPathComponent("search").appending(queryItems: [urlQueryItem]))
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            self.decodeData(data: data, completion: completion)
        }
        task.resume()
    }

    // post to async 
    func postAsyncProducts() async throws -> Data {
            var encodedProductModel: Data?
            encodedProductModel = try await encode(data: encodedProductModel)
            var request = URLRequest(url: baseUrl.appendingPathComponent("add"))
            request.httpMethod = "POST"
            request.httpBody = encodedProductModel
            var dataToPost = Data()
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print("RESPONSE:\(String(describing: response))")
                guard let data = data else { return  }
                dataToPost = data
            }
            task.resume()
            return dataToPost
        }
    
    func encode<T: Encodable>(data: T) async throws -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(data)
    }
    

    func postProductsData(model: ProductDataModel, completion: @escaping (Result<Data, Error>) -> Void) {
        
        var encodedProductModel: Data?
        encodedProductModel = initializeData(product: encodedProductModel)
        guard encodedProductModel != nil else { return }
        
        var request = URLRequest(url: baseUrl.appendingPathComponent("add"))
        request.httpMethod = "POST"
        request.httpBody = encodedProductModel
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            print("RESPONSE:\(String(describing: response))")
            guard let data = data else { return }
            completion(.success(data))
        }
        task.resume()
    }
    
    
    // put to async
    func putAsyncProducts(id: Int) async throws -> Data {
        var encodedProductModel: Data?
        encodedProductModel = try await encode (data: encodedProductModel)
        var request = URLRequest(url: baseUrl.appendingPathComponent("\(id)"))
        request.httpMethod = "PUT"
        request.httpBody = encodedProductModel
        var dataToPut = Data ()
        let task = URLSession.shared.dataTask(with: request) { data,
            response, error in
            print("RESPONSE:\(String(describing: response))")
            guard let data = data else { return }
            dataToPut = data
        }
        task.resume ()
        return dataToPut
    }
    
    
   func deleteProductsData(id: Int, completion: @escaping (Result<Data, Error>) -> Void) {
    
    var request = URLRequest(url: baseUrl.appendingPathComponent("\(id)"))
    request.httpMethod = "DELETE"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
        }
        print("RESPONSE:\(String(describing: response))")
    }
    task.resume()
}
  
    
    func encodeData<T: Encodable>(product: T, completion: @escaping (Result<Data, Error>) -> Void) {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(product)
            completion(.success(encodedData))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func initializeData<T: Encodable>(product: T) -> Data? {
        var encodedData: Data?
        encodeData(product: product) { result in
            switch result {
            case .success(let model):
                encodedData = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return encodedData
    }
}


