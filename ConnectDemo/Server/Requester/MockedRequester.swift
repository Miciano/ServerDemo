//
//  MockedRequester.swift
//  ConnectDemo
//
//  Created by Fabio Miciano on 21/12/2018.
//  Copyright © 2018 Fabio Miciano. All rights reserved.
//

import Foundation

class MockedRequester: Requester {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func createURLRequestWith(endPoint: String, method: Method, parameters: [String : Any]?) throws -> URLRequest {
        let bundle = Bundle(for: MockedRequester.self)
        guard let url = bundle.url(forResource: "loginMock", withExtension: "json") else {
            print("\(errorTitle): JSON MOCK NOT FIND")
            throw Errors.invalidURL
        }

        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let parameters = parameters {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        }

        return urlRequest
    }
    
    func requestWith<T>(endPoint: String, method: Method, parameters: [String: Any]?, type: T.Type) throws -> T? where T: Decodable {
        guard let request = try? self.createURLRequestWith(endPoint: endPoint, method: method, parameters: parameters) else {
            print("\(errorTitle): ERRO OF CREATE URL REQUEST")
            throw Errors.invalidRequest
        }

        var dataRequest: Data?
        var errorRequest: Error?

        self.session.dataTask(with: request) { (data, response, error) in
            dataRequest = data
            errorRequest = error
        }.resume()

        if let data = dataRequest {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        }
        
        if let error = errorRequest {
            print("\(errorTitle): \(error)")
            throw error
        }
        
        print("\(errorTitle): ERROR ON REQUEST")
        throw Errors.serverError
    }
}