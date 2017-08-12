//
//  BaseController.swift
//  Playground
//
//  Created by Jack Lai on 12/08/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

class BaseController: UIViewController {
    
    func setupBackButton(color: UIColor) {
        let backButton = UIButton(type: .system)
        backButton.tintColor = color
        backButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(40)
            make.left.equalTo(view).offset(20)
        }
    }
    
    @objc fileprivate func back() {
        dismiss(animated: true, completion: nil)
    }
    
}
