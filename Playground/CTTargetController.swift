//
//  CTTargetController.swift
//  Playground
//
//  Created by Jack Lai on 16/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

class CTTargetController: UIViewController {
    
    let buttonSize: CGFloat = 80
    let button = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.setTitle("X", for: .normal)
        button.setTitleColor(UIColor("#4E6BCC"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .white
        button.layer.cornerRadius = buttonSize / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        view.backgroundColor = UIColor("#4E6BCC")
        view.addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(buttonSize)
            make.center.equalTo(view)
        }
    }
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}
