//
//  DataRequest.swift
//  RestaurantSearcher2
//
//  Created by 渡邊 翔矢 on 2024/03/29.
//

import Foundation
import UIKit
import CoreLocation

class Datarequest {
    let deligate = UIApplication.shared.delegate as! AppDelegate
    func request(_ after:@escaping([String],[Double],[Double]) -> ()) {
        let apiKey = "cd0573e866605722"
        //        検索時、配列リセット
        self.deligate.resultName.removeAll()
        self.deligate.resultLat.removeAll()
        self.deligate.resultLng.removeAll()
        self.deligate.resultUrl.removeAll()
        
        let prams: [String: Any] = [
            "key": apiKey,
            "keyword": deligate.userSearchKeyword,
            "lat": deligate.userLat,
            "lng": deligate.userLng,
            "range": 5,
            "count": 2,
            "format": "json",
        ]
        
        guard let url = URL(string: "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let results = json["results"] as? [String: Any], let shops = results["shop"] as? [[String: Any]] {
                        for i in 0..<min(2, shops.count) {
                            let name = shops[i]["name"] as? String
                            let lat = shops[i]["lat"] as? Double
                            let lng = shops[i]["lng"] as? Double
                            let url = (shops[i]["urls"] as? [String: String])?["pc"]
                            
                            if let name = name, let lat = lat, let lng = lng, let url = url {
                                self.deligate.resultName.append(name)
                                self.deligate.resultLat.append(lat)
                                self.deligate.resultLng.append(lng)
                                self.deligate.resultUrl.append(url)
                            }
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                after(self.deligate.resultName, self.deligate.resultLat, self.deligate.resultLng)
            }
        }.resume()
    }
}
