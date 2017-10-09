//
//  AppUpdateFunctions.swift
//  tassk
//
//  Created by Erstream on 01/10/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

class AppUpdateFunctions {
  
  init() {
    
  }
  
  func getLastCheckDateFromDisc () -> String {
    if let lastCheckDateOnDisc = UserDefaults.standard.string(forKey: lastCheckDateKey) as String? {

      return lastCheckDateOnDisc
    }
    return ""
  }
  
  func compareVersionStrings (storeVersion: String, currentVersion: String) -> Bool {
    
    if storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
      return true // update is available
    } else {
      return false // update is not available
    }
  }
  
  func parseUpdateJsonData (data: Data) -> Int? {
    
    do {
      if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
        let versionNumber = json["avaliable-version"] as? Int {
        return versionNumber
      }
    } catch {
      print("Error deserializing JSON: \(error)")
    }
    return nil
  }
  
  
  func getUpdateStatusFromDisc () -> Bool {
    // if any data is available return the data, else return false
    if let updateStatus = UserDefaults.standard.bool(forKey: updateIsAvailableKey) as Bool? {
      return updateStatus
    }
    return false
  }
  
  func getUpdateDataFromRemote (completionHandler:@escaping (Data) -> ()) {
    
    let requestURL: URL = URL(string:  "http://web.itu.edu.tr/hatipoglufu/tassk/tassk_version.json")!
    var urlRequest: URLRequest = URLRequest(url: requestURL)
    urlRequest.cachePolicy = .reloadIgnoringCacheData
    let task = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) -> Void in
      
      if let data = data {
        completionHandler(data)
      }
    }
    task.resume()
  }
  
}
