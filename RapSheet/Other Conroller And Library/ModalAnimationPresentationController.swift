//
//  ModalAnimationPresentationController.swift
//  RapSheet
//

import UIKit

class ModalAnimationPresentationController: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: Variables
    let isPresenting: Bool
    let duration: TimeInterval = 0.3
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        } else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let containerView = transitionContext.containerView
        presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
        presentedControllerView.alpha = 0.1
        containerView.addSubview(presentedControllerView)
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            presentedControllerView.alpha = 1.0
        }, completion: {
            (completed: Bool) -> Void in
            transitionContext.completeTransition(completed)
        })
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            presentedControllerView?.alpha = 0.0
        }, completion: {
            (completed: Bool) -> Void in
            transitionContext.completeTransition(completed)
        })
    }
}
