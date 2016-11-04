//
//  MCMHeaderAnimated.swift
//  MCMHeaderAnimated
//
//  Created by Mathias Carignani on 5/19/15.
//  Copyright (c) 2015 Mathias Carignani. All rights reserved.
//

import UIKit

@objc public protocol MCMHeaderAnimatedDelegate {
    
    func headerView() -> UIView
    
    func headerCopy(_ subview: UIView) -> UIView
    
}

open class MCMHeaderAnimated: UIPercentDrivenInteractiveTransition {
    
    open var transitionMode: TransitionMode = .present
    open var transitionInteracted: Bool = false
    
    fileprivate var headerFromFrame: CGRect! = nil
    fileprivate var headerToFrame: CGRect! = nil
    
    fileprivate var enterPanGesture: UIPanGestureRecognizer!
    open var destinationViewController: UIViewController! {
        didSet {
            self.enterPanGesture = UIPanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action: #selector(self.handleOnstagePan(_:)))
            self.destinationViewController.view.addGestureRecognizer(self.enterPanGesture)
            self.transitionInteracted = true
        }
    }
    
    public enum TransitionMode: Int {
        case present, dismiss
    }
    
    func handleOnstagePan(_ pan: UIPanGestureRecognizer){
        
        let translation = pan.translation(in: pan.view!)
        let d =  translation.y / pan.view!.bounds.height * 1.5
        
        switch (pan.state) {
            case UIGestureRecognizerState.began:
            
                self.destinationViewController.dismiss(animated: true, completion: nil)
            break
            case .changed:
                
                self.update(d)
            break
            
            default: // .Ended, .Cancelled, .Failed ...
                
                self.finish()
        }
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning

extension MCMHeaderAnimated: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.65
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let duration = self.transitionDuration(using: transitionContext)
        
        fromView.setNeedsLayout()
        fromView.layoutIfNeeded()
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        
        let alpha: CGFloat = 0.1
        let offScreenBottom = CGAffineTransform(translationX: 0, y: container.frame.height)

        // Prepare header
        let headerTo = (toController as! MCMHeaderAnimatedDelegate).headerView()
        let headerFrom = (fromController as! MCMHeaderAnimatedDelegate).headerView()
        
        if self.transitionMode == .present {
            self.headerToFrame = headerTo.superview!.convert(headerTo.frame, to: nil)
            self.headerFromFrame = headerFrom.superview!.convert(headerFrom.frame, to: nil)
        }
        
        headerFrom.alpha = 0
        headerTo.alpha = 0
        let headerIntermediate = (fromController as! MCMHeaderAnimatedDelegate).headerCopy(headerFrom)
        headerIntermediate.frame = self.transitionMode == .present ? self.headerFromFrame : self.headerToFrame
        
        if self.transitionMode == .present {
            toView.transform = offScreenBottom
            
            container.addSubview(fromView)
            container.addSubview(toView)
            container.addSubview(headerIntermediate)
        } else {
            toView.alpha = alpha
            container.addSubview(toView)
            container.addSubview(fromView)
            container.addSubview(headerIntermediate)
        }
        
        // Perform de animation
        UIView.animate(withDuration: duration, delay: 0.0, options: [], animations: {
            
            if self.transitionMode == .present {
                fromView.alpha = alpha
                toView.transform = CGAffineTransform.identity
                headerIntermediate.frame = self.headerToFrame
            } else {
                fromView.transform = offScreenBottom
                toView.alpha = 1.0
                headerIntermediate.frame = self.headerFromFrame
            }
            
            }, completion: { finished in
                
                headerIntermediate.removeFromSuperview()
                headerTo.alpha = 1
                headerFrom.alpha = 1
                
                transitionContext.completeTransition(true)
                
        })
        
    }
    
}

extension MCMHeaderAnimated {
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
    }

}

extension MCMHeaderAnimated: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transitionMode = .present
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transitionMode = .dismiss
        return self
        
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.transitionInteracted ? self : nil
    }
    
}
