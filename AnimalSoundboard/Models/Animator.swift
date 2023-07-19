//
//  Animator.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 05.06.2020.
//  Copyright © 2020 Danil Andriuschenko. All rights reserved.
//

import Foundation
import UIKit
class Animator: NSObject, UIViewControllerAnimatedTransitioning{
    var isPresenting = false
    func animationType(transitionContext: UIViewControllerContextTransitioning?) -> AnimationType{
        guard let viewController = isPresenting ? transitionContext?.viewController(forKey: .to) : transitionContext?.viewController(forKey: .from) else{
            return .picker
        }
        if viewController is CustomPicker{
            return .picker
        }
        return .picker
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        var duration: Double = 0.6
        
        let type = animationType(transitionContext: transitionContext)
        
        duration = 0.3//isPresenting ? 0.3
        
        
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let viewController = isPresenting ? transitionContext.viewController(forKey: .to) : transitionContext.viewController(forKey: .from){
            let containerView = transitionContext.containerView
        
            
            containerView.addSubview(viewController.view)
            containerView.sendSubviewToBack(viewController.view)

            var type: AnimationType!
            if viewController is CustomPicker{
                type = .picker
            }
            
            animation(containerView: containerView, viewController: viewController, type: type, transitionContext: transitionContext)
            
        }
    }
    func animation(containerView: UIView, viewController: UIViewController, type: AnimationType, transitionContext: UIViewControllerContextTransitioning){
        let duration = transitionDuration(using: transitionContext)
        viewController.view.layoutIfNeeded()
        switch type {
        case .picker:
            if isPresenting{
                viewController.view.alpha = 0
            }
            let currentViewControllerView = (viewController as? CustomPicker)?.currentViewController?.view.snapshotView(afterScreenUpdates: true)
            let fantomMainView = CustomPickerView(actions: (viewController as? CustomPicker)?.actions ?? [])
            if let mainViewXPosition = (viewController as? CustomPicker)?.mainViewXPosition{
                switch mainViewXPosition{
                case .right:
                    fantomMainView.layer.anchorPoint.x = 1
                    break
                case .center:
                    fantomMainView.layer.anchorPoint.x = 0.5
                    break
                case .left:
                    fantomMainView.layer.anchorPoint.x = 0
                    break
                }
            }
            if let mainViewYPosition = (viewController as? CustomPicker)?.mainViewYPosition{
                switch mainViewYPosition{
                case .top(_):
                    fantomMainView.layer.anchorPoint.y = 1
                    break
                case .bottom(_):
                    fantomMainView.layer.anchorPoint.y = 0
                    break
                }
            }
            
            viewController.view.layoutIfNeeded()
            fantomMainView.frame = (viewController as? CustomPicker)?.mainView.frame ?? CGRect.zero
            
            
            fantomMainView.addSubview(currentViewControllerView!)
            
            
            
            fantomMainView.alpha = self.isPresenting ? 0 : 1
            
            containerView.addSubview(fantomMainView)
            
            
            if !isPresenting{
                viewController.view.alpha = 0
            }
            fantomMainView.transform = self.isPresenting ? CGAffineTransform(scaleX: 0.2, y: 0.2) : CGAffineTransform(scaleX: 1, y: 1)
            
            
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: isPresenting ? 0.8 : 1, initialSpringVelocity: isPresenting ? 0.8 : 1, options: [.curveEaseOut]) {
                fantomMainView.alpha = self.isPresenting ? 1 : 0
                fantomMainView.transform = self.isPresenting ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: 0.2, y: 0.2)
            } completion: { _ in
                fantomMainView.removeFromSuperview()
                viewController.view.alpha = 1
                transitionContext.completeTransition(true)
            }
            
        }
      
    }
    enum AnimationType{
        case picker
    }
    
}
extension Animator: UIViewControllerTransitioningDelegate{
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        
        return self
    }
}
