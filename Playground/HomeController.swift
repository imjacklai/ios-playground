//
//  HomeController.swift
//  Playground
//
//  Created by Jack Lai on 16/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

class HomeController: UITableViewController {
    
    private let items = [
        "Circular Transition",
        "Speech To Text",
        "Barcode Scanner",
        "Image Recognition"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Playground"
        tableView.rowHeight = 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        cell?.detailTextLabel?.text = items[indexPath.row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            present(CTSourceController(), animated: true, completion: nil)
        case 1:
            present(SpeechController(), animated: true, completion: nil)
        case 2:
            present(BarCodeScannerController(), animated: true, completion: nil)
        case 3:
            if #available(iOS 11.0, *) {
                navigationController?.pushViewController(ImageRecognitionController(), animated: true)
            } else {
                let controller = UIAlertController(title: "裝置版本不符", message: "需要iOS 11版本以上", preferredStyle: .alert)
                let action = UIAlertAction(title: "確定", style: .default, handler: nil)
                controller.addAction(action)
                present(controller, animated: true, completion: nil)
            }
        default:()
        }
    }
    
}
