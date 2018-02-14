//
//  APIInteractor.swift
//  News
//
//  Created by Sergey Roslyakov on 2/13/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//

import UIKit

class APIInteractor {
    
    typealias newsCompletionBlock = ((_ result:[Title]?, _ error:NSError?) -> Void)
    typealias newsDetailCompletionBlock = ((_ result:Payload?, _ error:NSError?) -> Void)

    struct Pagination {
        var first = 0
        var last = 0
    }
    
    enum ErrorsType:Int {
        case parsingError = 0
        case undefinedError = 1
        case noInternetConnection = 2
    }
    
    static let shared = APIInteractor()

    fileprivate let baseURLString = "https://api.tinkoff.ru/v1/"
    fileprivate let errorDomain = "APIInteractorError"
    
    func getNews(pagination:Pagination, completion:@escaping newsCompletionBlock) {
        let url = URL(string: "\(baseURLString)news?first=\(pagination.first)&last=\(pagination.last)")
        let task = URLSession.shared.dataTask(with: url!) { [unowned self] (data, response, error) in
            if error != nil, let err = error as NSError? {
                if err.code == -1009 {
                    completion(nil, self.getError(for: .noInternetConnection, underlyingError: nil))
                    return
                }
                completion(nil, self.getError(for: .undefinedError, underlyingError: nil))
                return
            }
            guard let data = data else {
                completion(nil, self.getError(for: .undefinedError, underlyingError: nil))
                return
            }
            do {
                var response = try JSONDecoder().decode(ResponseNews.self, from: data)
                for index in response.payload.indices {
                    response.payload[index].text = response.payload[index].text.stringByDecodingHTMLEntities
                }
                completion(response.payload, nil)
            } catch let parsingError {
                completion(nil, self.getError(for: .parsingError, underlyingError: parsingError as NSError))
            }
        }
        task.resume()
    }
    
    
    func getDetailNews(byID id:String, completion:@escaping newsDetailCompletionBlock) {
        let url = URL(string: "\(baseURLString)news_content?id=\(id)")
        let task = URLSession.shared.dataTask(with: url!) { [unowned self] (data, response, error) in
            if error != nil, let err = error as NSError? {
                if err.code == -1009 {
                    completion(nil, self.getError(for: .noInternetConnection, underlyingError: nil))
                    return
                }
                completion(nil, self.getError(for: .undefinedError, underlyingError: nil))
                return
            }
            guard let data = data else {
                completion(nil, self.getError(for: .undefinedError, underlyingError: nil))
                return
            }
            do {
                var response = try JSONDecoder().decode(ResponseDetailNews.self, from: data)
                response.payload.title.text = response.payload.title.text.stringByDecodingHTMLEntities
                completion(response.payload, nil)
            } catch let parsingError {
                completion(nil, self.getError(for: .parsingError, underlyingError: parsingError as NSError))
            }
        }
        task.resume()
    }
    
    func getError(for type:ErrorsType, underlyingError:NSError?) -> NSError {
        var error = NSError()
        
        switch type {
        case .parsingError:
            error = NSError(domain:self.errorDomain,
                            code: ErrorsType.parsingError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey:"Ошибка обработки данных",
                                       NSUnderlyingErrorKey: underlyingError ?? NSError()])
        case .undefinedError:
            error = NSError(domain:self.errorDomain,
                            code: ErrorsType.undefinedError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey:"Неизвестная ошибка"])
            
        case .noInternetConnection:
            error = NSError(domain:self.errorDomain,
                            code: ErrorsType.noInternetConnection.rawValue,
                            userInfo: [NSLocalizedDescriptionKey:"Проверьте интернет соединение"])
        }
        
        return error
    }
}
