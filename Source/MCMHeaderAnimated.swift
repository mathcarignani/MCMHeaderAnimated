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

public class MCMHeaderAnimated: NSObject {
    
    public var transitionMode: TransitionMode = .Present
    
    private var headerFromFrame: CGRect! = nil
    private var headerToFrame: CGRect! = nil
    
    public enum TransitionMode: Int {
        case Present, Dismiss
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
        
        if self.transitionMode == .Present {
            
            let scale = CGAffineTransformMakeScale(0.8, 0.8)
            let offScreenBottom = CGAffineTransformMakeTranslation(0, container.frame.height)
            
            // Prepare header
            let headerTo = (toController as! MCMHeaderAnimatedDelegate).headerView()
            let headerFrom = (fromController as! MCMHeaderAnimatedDelegate).headerView()
            
            self.headerToFrame = headerTo.superview!.convertRect(headerTo.frame, toView: nil)
            self.headerFromFrame = headerFrom.superview!.convertRect(headerFrom.frame, toView: nil)
            
            headerFrom.alpha = 0
            headerTo.alpha = 0
            let headerIntermediate = (fromController as! MCMHeaderAnimatedDelegate).headerCopy(headerFrom)
            headerIntermediate.frame = self.headerFromFrame
            
            // Prepare initial states
            toView.transform = offScreenBottom
            
            // Add subviews
            container.addSubview(fromView)
            container.addSubview(toView)
            container.addSubview(headerIntermediate)
            
            // Perform de animation
            UIView.animateWithDuration(duration, delay: 0.0, options: nil, animations: {
                
                toView.transform = CGAffineTransformIdentity
                headerIntermediate.frame = self.headerToFrame
                
                }, completion: { finished in
                    
                    headerIntermediate.removeFromSuperview()
                    headerTo.alpha = 1
                    headerFrom.alpha = 1
                    
                    transitionContext.completeTransition(true)
                    
            })
            
        } else if self.transitionMode == .Dismiss {
            
            let scale = CGAffineTransformMakeScale(0.8, 0.8)
            let offScreenBottom = CGAffineTransformMakeTranslation(0, container.frame.height)
            
            // Prepare header
            let headerTo = (toController as! MCMHeaderAnimatedDelegate).headerView()
            let headerFrom = (fromController as! MCMHeaderAnimatedDelegate).headerView()
            
            headerFrom.alpha = 0
            headerTo.alpha = 0
            let headerIntermediate = (fromController as! MCMHeaderAnimatedDelegate).headerCopy(headerFrom)
            headerIntermediate.frame = self.headerToFrame
            
            // Add subviews
            container.addSubview(toView)
            container.addSubview(fromView)
            container.addSubview(headerIntermediate)
            
            // Perform de animation
            UIView.animateWithDuration(duration, delay: 0.0, options: nil, animations: {
                
                fromView.transform = offScreenBottom
                headerIntermediate.frame = self.headerFromFrame
                
                }, completion: { finished in
                    
                    headerIntermediate.removeFromSuperview()
                    headerTo.alpha = 1
                    headerFrom.alpha = 1
                    
                    transitionContext.completeTransition(true)
                    
            })
            
        }
        
    }
    
}