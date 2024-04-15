//
//  Factory.swift
//  ParkScan
//
//  Created by שגב פרץ on 15/04/2024.
//

import UIKit

struct Factory {
    private init(){}
    static let shared = Factory()
    
    static func redirectAlertController() -> UIAlertController {
        let alert = UIAlertController(title: "You're missing an api key", message: "Go and generate one", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Go to ChatGPT website", style: .default, handler: { action in
            guard let url = URL(string: "https://platform.openai.com/api-keys"),
            UIApplication.shared.canOpenURL(url)
            else {
                action.isEnabled = false
                return
            }
            UIApplication.shared.open(url)
        }))
        
        return alert
    }
}
