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
    
    public enum TransitionMode: Int {
        case Present, Dismiss
    }
    
    public var mode: TransitionMode = .Present
    
    private var interactive = false
    
    private lazy var panGesture = UIPanGestureRecognizer()
    
    public var destinationViewController: UIViewController? {
        didSet {
            panGesture.addTarget(self, action: "handlePan:")
            destinationViewController?.view.addGestureRecognizer(panGesture)
        }
    }
    
    private var headerToFrame = CGRect()
    private var headerFromFrame = CGRect()
    
    // MARK:
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if let
            destinationViewController = destinationViewController,
            view = recognizer.view
        {
            let translation = recognizer.translationInView(view)
            let delta = translation.y / view.bounds.height * 1.5
            
            switch (recognizer.state) {
                case .Began:
                    if let headerView = (destinationViewController.topMostViewController() as? MCMHeaderAnimatedDelegate)?.headerView() {
                        interactive = true
                        destinationViewController.dismissViewControllerAnimated(true, completion: nil)
                    }
                case .Changed:
                    self.updateInteractiveTransition(delta)
                default:
                    interactive = false
                    if delta > 0.5 {
                        self.finishInteractiveTransition()
                    } else {
                        self.cancelInteractiveTransition()
                    }
            }
        }
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension MCMHeaderAnimated: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.65
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.topMostViewController()
        let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.topMostViewController()
        
        let duration = self.transitionDuration(transitionContext)
        
        fromView.setNeedsLayout()
        fromView.layoutIfNeeded()
        toView.setNeedsLayout()
        toView.layoutIfNeeded()
        
        let alpha: CGFloat = 0.1
        let offScreenBottom = CGAffineTransformMakeTranslation(0, container!.frame.height)
        
        let headerTo = (toController as! MCMHeaderAnimatedDelegate).headerView()
        let headerFrom = (fromController as! MCMHeaderAnimatedDelegate).headerView()
        
        if mode == .Present {
            headerToFrame = headerTo.superview!.convertRect(headerTo.frame, toView: nil)
            headerFromFrame = headerFrom.superview!.convertRect(headerFrom.frame, toView: nil)
        }
        
        headerFrom.alpha = 0
        headerTo.alpha = 0
        let headerIntermediate = (fromController as! MCMHeaderAnimatedDelegate).headerCopy(headerFrom)
        headerIntermediate.frame = mode == .Present ? headerFromFrame : headerToFrame
        
        if mode == .Present {
            toView.transform = offScreenBottom
            container!.addSubview(fromView)
            container!.addSubview(toView)
            container!.addSubview(headerIntermediate)
        } else {
            toView.alpha = alpha
            container!.addSubview(toView)
            container!.addSubview(fromView)
            container!.addSubview(headerIntermediate)
        }
        
        UIView.animateWithDuration(duration, delay: 0.0, options: [], animations: {
            if self.mode == .Present {
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
            if transitionContext.transitionWasCancelled() {
                transitionContext.completeTransition(false)
            } else {
                transitionContext.completeTransition(true)
            }
        })
        
    }
    
}

extension MCMHeaderAnimated: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        mode = .Present
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        mode = .Dismiss
        return self
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive ? self : nil
    }
    
}

private extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            if let visibleViewController = navigation.topViewController {
                return visibleViewController.topMostViewController()
            }
        }
        if let tab = self as? UITabBarController {
            if let selectedViewController = tab.selectedViewController {
                return selectedViewController.topMostViewController()
            }
        }
        return self
    }
    
}
