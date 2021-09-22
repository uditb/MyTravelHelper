//
//  ServiceManager.swift
//  MVVM-Demo
//
//  Created by Udit Batra on 12/09/21.
//

import Foundation

enum ServiceResponse <Data, error: Error>{
    case success(Data)
    case failure(error)
}

enum HTTPError: Error{
    case dataError
    case jsonError
    case networkError
}

class ServiceManager{
    private var dataTask : URLSessionDataTask?
    
    func requestServer(strUrl : String, params: [AnyHashable: Any]?, completionBlock: @escaping (_ serviceResponse: ServiceResponse<Data, HTTPError>) -> Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: strUrl)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        dataTask =  URLSession.shared.dataTask(
            with: request as URLRequest,
            completionHandler: { [weak self] (data, response, error) -> Void in
                
                if (error != nil) {
                    completionBlock(.failure(.networkError))
                } else {
                    if data != nil{
                        completionBlock(.success(data! as Data))
                    }else{
                        completionBlock(.failure(.dataError))
                    }
                }
                self?.dataTask = nil
            })
        dataTask!.resume()
    }
}



