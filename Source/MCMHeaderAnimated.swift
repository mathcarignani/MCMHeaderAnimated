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
    
    func headerCopy(subview: UIView) -> UIView
    
}

public class MCMHeaderAnimated: UIPercentDrivenInteractiveTransition {
    
    public var transitionMode: TransitionMode = .Present
    public var transitionInteracted: Bool = false
    
    private var headerFromFrame: CGRect! = nil
    private var headerToFrame: CGRect! = nil
    
    private var enterPanGesture: UIPanGestureRecognizer!
    public var destinationViewController: UIViewController! {
        didSet {
            self.enterPanGesture = UIPanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action: #selector(handleOnstagePan))
            self.destinationViewController.view.addGestureRecognizer(self.enterPanGesture)
            self.transitionInteracted = true
        }
    }
    
    public enum TransitionMode: Int {
        case Present, Dismiss
    }
    
    @objc func handleOnstagePan(pan: UIPanGestureRecognizer){
        
        let translation = pan.translation(in: pan.view!)
        let d =  translation.y / (pan.view?.bounds.height)! * 1.5 //CGRectGetHeight(pan.view!.bounds) * 1.5
        
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
        
        if self.transitionMode == .Present {
            self.headerToFrame = headerTo.superview!.convert(headerTo.frame, to: nil)
            self.headerFromFrame = headerFrom.superview!.convert(headerFrom.frame, to: nil)
        }
        
        headerFrom.alpha = 0
        headerTo.alpha = 0
        let headerIntermediate = (fromController as! MCMHeaderAnimatedDelegate).headerCopy(subview: headerFrom)
        headerIntermediate.frame = self.transitionMode == .Present ? self.headerFromFrame : self.headerToFrame
        
        if self.transitionMode == .Present {
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
            
            if self.transitionMode == .Present {
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
    
    public override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
    }
    
}

extension MCMHeaderAnimated: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transitionMode = .Present
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transitionMode = .Dismiss
        return self
        
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.transitionInteracted ? self : nil
    }
    
}

