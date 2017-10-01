//
//  CircularTransition.swift
//  Playground
//
//  Created by Jack Lai on 16/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit

class CircularTransition: NSObject {
    
    enum TransitionMode: Int {
        case present, dismiss, pop
    }
    
    private var circleView = UIView()
    private var duration = 0.3
    
    var circleColor = UIColor.white
    var startPoint = CGPoint.zero
    var transitionMode = TransitionMode.present
    
    private func circleFrame(viewCenter: CGPoint, viewSize: CGSize, startPoint: CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
        let offsetVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offsetVector, height: offsetVector)
        return CGRect(origin: .zero, size: size)
    }
}

extension CircularTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if transitionMode == .present {
            guard let presentedView = transitionContext.view(forKey: .to) else { return }
            
            let viewCenter = presentedView.center
            let viewSize = presentedView.frame.size
            
            circleView = UIView()
            circleView.frame = circleFrame(viewCenter: viewCenter, viewSize: viewSize, startPoint: startPoint)
            circleView.layer.cornerRadius = circleView.frame.height / 2
            circleView.center = startPoint
            circleView.backgroundColor = circleColor
            circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            containerView.addSubview(circleView)
            
            presentedView.center = startPoint
            presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            presentedView.alpha = 0
            containerView.addSubview(presentedView)
            
            UIView.animate(withDuration: duration, animations: {
                self.circleView.transform = .identity
                presentedView.transform = .identity
                presentedView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
        } else {
            let transitionModeKey = transitionMode == .pop ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            
            guard let presentingView = transitionContext.view(forKey: transitionModeKey) else { return }

            let viewCenter = presentingView.center
            let viewSize = presentingView.frame.size
            
            circleView.frame = circleFrame(viewCenter: viewCenter, viewSize: viewSize, startPoint: startPoint)
            circleView.layer.cornerRadius = circleView.frame.height / 2
            circleView.center = startPoint
            
            UIView.animate(withDuration: duration, animations: {
                self.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                presentingView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                presentingView.alpha = 0
                
                if self.transitionMode == .pop {
                    containerView.insertSubview(presentingView, belowSubview: presentingView)
                    containerView.insertSubview(self.circleView, belowSubview: presentingView)
                }
            }, completion: { (finished) in
                presentingView.removeFromSuperview()
                self.circleView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            })
        }
    }
    
}
