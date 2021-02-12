//
//  ModalPresentationController.swift
//  RapSheet
//


import UIKit

class ModalPresentationController: UIPresentationController {
    
    var blurEffectView: UIVisualEffectView?
    var height: CGFloat = 240.0

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        blurEffectView?.addGestureRecognizer(tapGesture)
    }
    
    override func presentationTransitionWillBegin() {
        
        self.blurEffectView?.alpha = 0
        
        self.containerView?.addSubview(blurEffectView ?? UIVisualEffectView())
        
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView?.alpha = 1
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.layer.masksToBounds = true
        presentedView?.layer.cornerRadius = 8
    }
    
    override func containerViewDidLayoutSubviews() {
        
        super.containerViewDidLayoutSubviews()
        self.presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView?.frame = containerView!.bounds
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView?.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView?.removeFromSuperview()
        })
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        guard let containerView = containerView else {
            return CGRect()
        }
        
        let containerViewBounds = containerView.bounds
        
        // Center the presentationWrappingView view within the container.
        var frame = CGRect.zero
        let gap: CGFloat = 40.0
        let width = containerViewBounds.size.width - gap
        let restOftheWidth = (containerViewBounds.size.width - width)
        
        if #available(iOS 11.0, *) {
            
            frame = CGRect(x: restOftheWidth / 2, y: (containerViewBounds.size.height - (containerView.safeAreaInsets.top + 64.0 + height)) / 2.0, width: width, height: height)
        } else {
            // Fallback on earlier versions
            frame = CGRect(x: restOftheWidth / 2, y: ((containerViewBounds.size.height - 64.0) + height) / 2.0, width: width, height: height)
        }
        return frame
    }
    
    override func viewWillTransition(to size: CGSize, with transitionCoordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: transitionCoordinator)
        
        guard let containerView = containerView else {
            return
        }
        
        transitionCoordinator.animate(alongsideTransition: {
            (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.blurEffectView?.frame = containerView.bounds
        }, completion:nil)
    }
    
    @objc func backgroundViewTapped() {
//        presentingViewController.dismiss(animated: true, completion: nil)
    }
}
