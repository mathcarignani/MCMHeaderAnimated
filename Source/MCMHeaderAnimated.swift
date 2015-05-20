//
//  MCMHeaderAnimated.swift
//  MCMHeaderAnimated
//
//  Created by Mathias Carignani on 5/19/15.
//  Copyright (c) 2015 Mathias Carignani. All rights reserved.
//

import UIKit

public protocol MCMHeaderAnimatedDelegate {
    
    func headerView() -> UIView
    
    func headerCopy(subview: UIView) -> UIView
    
}

public class MCMHeaderAnimated: UIPercentDrivenInteractiveTransition {
    
    public var transitionMode: TransitionMode = .Present
    
    private var headerFromFrame: CGRect! = nil
    private var headerToFrame: CGRect! = nil
    
    private var enterPanGesture: UIPanGestureRecognizer!
    
    public enum TransitionMode: Int {
        case Present, Dismiss
    }
    
    public var destinationViewController: UIViewController! {
        didSet {
            self.enterPanGesture = UIPanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action: "handleOnstagePan:")
            self.destinationViewController.view.addGestureRecognizer(self.enterPanGesture)
        }
    }
    
    // TODO: We need to complete this method to do something useful
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        
        let translation = pan.translationInView(pan.view!)
        let d =  translation.y / CGRectGetHeight(pan.view!.bounds) * 1.5
        
        switch (pan.state) {
            case UIGestureRecognizerState.Began:
            
                self.destinationViewController.dismissViewControllerAnimated(true, completion: nil)
            break
            case .Changed:
                
                self.updateInteractiveTransition(d)
            break
            
            default: // .Ended, .Cancelled, .Failed ...
                
                self.finishInteractiveTransition()
        }
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning

extension MCMHeaderAnimated: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.65
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let duration = self.transitionDuration(transitionContext)
        
        fromView.setNeedsLayout()
        fromView.layoutIfNeeded()
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        
        let alpha: CGFloat = 0.7
        let offScreenBottom = CGAffineTransformMakeTranslation(0, container.frame.height)

        // Prepare header
        let headerTo = (toController as! MCMHeaderAnimatedDelegate).headerView()
        let headerFrom = (fromController as! MCMHeaderAnimatedDelegate).headerView()
        
        if self.transitionMode == .Present {
            self.headerToFrame = headerTo.superview!.convertRect(headerTo.frame, toView: nil)
            self.headerFromFrame = headerFrom.superview!.convertRect(headerFrom.frame, toView: nil)
        }
        
        headerFrom.alpha = 0
        headerTo.alpha = 0
        let headerIntermediate = (fromController as! MCMHeaderAnimatedDelegate).headerCopy(headerFrom)
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
        UIView.animateWithDuration(duration, delay: 0.0, options: nil, animations: {
            
            if self.transitionMode == .Present {
                fromView.alpha = alpha
                toView.transform = CGAffineTransformIdentity
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

extension MCMHeaderAnimated: UIViewControllerInteractiveTransitioning {
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
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
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
    
}