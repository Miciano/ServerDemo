//
//  ServerRequester.swift
//  ConnectDemo
//
//  Created by Fabio Miciano on 21/12/2018.
//  Copyright © 2018 Fabio Miciano. All rights reserved.
//

import Foundation
import os

class ServerRequester: Requester {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func createURLRequestWith(endPoint: String, method: Method, parameters: [String : Any]?) throws -> URLRequest {
        let requestEndPoint = "\(baseURL)\(endPoint)"
        
        os_log("%{public}@ URL", log: .init(subsystem: "REQUESTER", category: "URL REQUESTED"), type: .debug, debugTitle)
        
        guard let url = URL(string: requestEndPoint) else {
            os_log("%{public}@ INVALID ENDPOINT", log: .init(subsystem: "REQUESTER", category: "CREATE URL REQUEST"), type: .error, errorTitle)
            throw Errors.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        
        os_log("%{public}@ URL REQUEST CREATED", log: .init(subsystem: "REQUESTER", category: "CREATE URL REQUEST"), type: .info, infoTitle)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let parameters = parameters {
            os_log("%{public}@ HAVE PARAMETERS %{public}@", log: .init(subsystem: "REQUESTER", category: "PARAMENTERS"), type: .debug, debugTitle, parameters)
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        }

        return urlRequest
    }
    
    
    func requestWith(endPoint: String, method: Method, parameters: [String : Any]?, completion: @escaping RequesterCompletion) throws {
        guard let request = try? self.createURLRequestWith(endPoint: endPoint, method: method, parameters: parameters) else {
            os_log("%{public}@ ERRO OF CREATE URL REQUEST", log: .init(subsystem: "REQUESTER", category: "CREATE URL REQUEST"), type: .error, errorTitle)
            throw Errors.invalidRequest
        }
        
        os_log("%{public}@ REQUEST GOING TO START", log: .init(subsystem: "REQUESTER", category: "START REQUEST"), type: .info, infoTitle)
        
        self.session.dataTask(with: request) { (data, response, error) in
            os_log("%{public}@ HAVE ANSWER", log: .init(subsystem: "REQUESTER", category: "SERVE RESPONSE"), type: .info, infoTitle)
            completion(data, response, error)
        }.resume()
    }
}
