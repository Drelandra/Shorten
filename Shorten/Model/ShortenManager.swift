//
//  ShortenManager.swift
//  Shorten
//
//  Created by Andre Elandra on 16/06/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import Foundation

protocol ShortenManagerDelegate {
    //    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel)
    func didShortenURL(_ link: String)
    func didFailWithError(error: Error)
}

struct ShortenManager {
    
    var delegate: ShortenManagerDelegate?
    
    func getUrlShortener(for link: String) {
        let baseURL = URL(string: "https://rel.ink/api/links/")
        guard let requestUrl = baseURL else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let postString = "url=\(link)";
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            if let safeData = data  {
                if let dataString = String(data: safeData, encoding: .utf8){
                    print(dataString)
                }
                if let shorten = self.parseJSON(safeData){
                    let shortenString = "rel.ink/\(shorten)"
                    self.delegate?.didShortenURL(shortenString)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data: Data) -> String? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ShortenData.self, from: data)
            let id = decodedData.hashid
            
            return id
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
}

