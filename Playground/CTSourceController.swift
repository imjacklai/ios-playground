//
//  CTSourceController.swift
//  Playground
//
//  Created by Jack Lai on 16/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import SnapKit
import UIColor_Hex_Swift

class CTSourceController: UIViewController {
    
    let buttonSize: CGFloat = 80
    let button = UIButton(type: .system)
    let transition = CircularTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.setTitle("Tap!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor("#4E6BCC")
        button.layer.cornerRadius = buttonSize / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handlePresent), for: .touchUpInside)
        
        view.backgroundColor = .white
        view.addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(buttonSize)
            make.center.equalTo(view)
        }
    }
    
    func handlePresent() {
        let targetController = CTTargetController()
        targetController.transitioningDelegate = self
        targetController.modalPresentationStyle = .custom
        present(targetController, animated: true, completion: nil)
    }
    
}

extension CTSourceController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startPoint = button.center
        transition.circleColor = button.backgroundColor!
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startPoint = button.center
        transition.circleColor = button.backgroundColor!
        return transition
    }
    
}
